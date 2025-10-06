class Api::V1::Accounts::Saturn::AgentsController < Api::V1::Accounts::Saturn::BaseController
  before_action :set_agent_profile, only: [:show, :update, :destroy, :chat]
  
  def index
    @agents = Current.account.saturn_agent_profiles.ordered
  end
  
  def show; end
  
  def create
    @agent_profile = Current.account.saturn_agent_profiles.new(agent_params)
    
    if @agent_profile.save
      render :show, status: :created
    else
      render json: { 
        error: @agent_profile.errors.full_messages.join(', ') 
      }, status: :unprocessable_entity
    end
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
    
    api_key = Current.account.openai_api_key
    
    if api_key.blank?
      return render json: { 
        success: false, 
        error: 'OpenAI API key not configured. Please add it in Super Admin > Accounts.' 
      }, status: :unprocessable_entity
    end
    
    orchestrator = Saturn::Orchestrator.new(
      agent_profile: @agent_profile,
      api_key: api_key
    )
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
