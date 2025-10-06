class Api::V1::Accounts::Saturn::AgentsController < Api::V1::Accounts::Saturn::BaseController
  before_action :set_agent_profile, only: [:show, :update, :destroy, :chat]
  
  def index
    @agents = Current.account.saturn_agent_profiles.ordered
  end
  
  def show; end
  
  def create
    @agent = Current.account.saturn_agent_profiles.new(agent_params)
    @agent.save!
  end
  
  def update
    @agent_profile.update!(agent_params)
  end
  
  def destroy
    @agent_profile.destroy!
    head :no_content
  end
  
  def chat
    user_message = params[:message]
    context = params[:context] || {}
    
    orchestrator = Saturn::Orchestrator.new(agent_profile: @agent_profile)
    result = orchestrator.process(user_message, context: context)
    
    render json: result
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end
  
  private
  
  def set_agent_profile
    @agent_profile = Current.account.saturn_agent_profiles.find(params[:id])
  end
  
  def agent_params
    params.require(:agent).permit(
      :name,
      :description,
      :product_context,
      :ai_temperature,
      :active,
      :model_name,
      :model_provider,
      :max_tokens,
      behavior_rules: [],
      safety_guidelines: [],
      configuration: {}
    )
  end
end
