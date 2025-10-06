class Api::V1::Accounts::Saturn::KnowledgeSourcesController < Api::V1::Accounts::Saturn::BaseController
  before_action :set_knowledge_source, only: [:show, :update, :destroy]
  
  def index
    if params[:agent_id].present?
      @knowledge_sources = Current.account.saturn_knowledge_sources
                                          .for_agent(params[:agent_id])
                                          .ordered
    else
      @knowledge_sources = Current.account.saturn_knowledge_sources.ordered
    end
  end
  
  def show; end
  
  def create
    @knowledge_source = Current.account.saturn_knowledge_sources.new(knowledge_source_params)
    @knowledge_source.save!
  end
  
  def update
    @knowledge_source.update!(knowledge_source_params)
  end
  
  def destroy
    @knowledge_source.destroy!
    head :no_content
  end
  
  private
  
  def set_knowledge_source
    @knowledge_source = Current.account.saturn_knowledge_sources.find(params[:id])
  end
  
  def knowledge_source_params
    params.require(:knowledge_source).permit(
      :title,
      :source_url,
      :content_text,
      :source_type,
      :agent_profile_id,
      metadata: {}
    )
  end
end
