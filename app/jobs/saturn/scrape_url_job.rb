module Saturn
  class ScrapeUrlJob < ApplicationJob
    queue_as :default
    
    def perform(knowledge_source_id)
      knowledge_source = Saturn::KnowledgeSource.find_by(id: knowledge_source_id)
      return unless knowledge_source
      return unless knowledge_source.source_type == 'url'
      return if knowledge_source.source_url.blank?
      
      Rails.logger.info("Saturn: Scraping URL for knowledge source #{knowledge_source_id}: #{knowledge_source.source_url}")
      
      scraper = Saturn::UrlScraperService.new(knowledge_source.source_url)
      result = scraper.scrape
      
      if result[:success]
        knowledge_source.update!(
          title: result[:title] || knowledge_source.title,
          content_text: result[:content],
          metadata: (knowledge_source.metadata || {}).merge(
            last_scraped_at: Time.current.iso8601,
            scraping_status: 'success'
          )
        )
        Rails.logger.info("Saturn: Successfully scraped URL for knowledge source #{knowledge_source_id}")
      else
        knowledge_source.update!(
          metadata: (knowledge_source.metadata || {}).merge(
            last_scraped_at: Time.current.iso8601,
            scraping_status: 'failed',
            scraping_error: result[:error]
          )
        )
        Rails.logger.error("Saturn: Failed to scrape URL for knowledge source #{knowledge_source_id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Saturn: ScrapeUrlJob error for #{knowledge_source_id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
