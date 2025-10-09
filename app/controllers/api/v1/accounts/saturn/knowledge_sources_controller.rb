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
    # Check URL limit for URL sources
    if knowledge_source_params[:source_type] == 'url'
      max_urls = GlobalConfigService.load('MAX_URL_SOURCES_PER_ACCOUNT', '100').to_i
      current_url_count = Current.account.saturn_knowledge_sources.where(source_type: 'url').count
      
      if current_url_count >= max_urls
        render json: { 
          error: "URL kaynak limiti aşıldı. Maksimum #{max_urls} URL kaynağı ekleyebilirsiniz." 
        }, status: :unprocessable_entity
        return
      end
    end
    
    @knowledge_source = Current.account.saturn_knowledge_sources.new(knowledge_source_params)
    @knowledge_source.save!
    
    # Auto-scrape URL sources
    if @knowledge_source.source_type == 'url' && @knowledge_source.source_url.present?
      Saturn::ScrapeUrlJob.perform_later(@knowledge_source.id)
    end
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
