module Saturn
  class DailyUrlSyncJob < ApplicationJob
    queue_as :scheduled_jobs
    
    def perform
      Rails.logger.info("Saturn: Starting daily URL sync for all knowledge sources")
      
      # Find all URL-type knowledge sources
      url_sources = Saturn::KnowledgeSource.where(source_type: 'url')
                                           .where.not(source_url: nil)
      
      Rails.logger.info("Saturn: Found #{url_sources.count} URL sources to sync")
      
      url_sources.find_each do |knowledge_source|
        # Queue individual scraping jobs
        Saturn::ScrapeUrlJob.perform_later(knowledge_source.id)
      end
      
      Rails.logger.info("Saturn: Daily URL sync jobs queued successfully")
    rescue StandardError => e
      Rails.logger.error("Saturn: DailyUrlSyncJob error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
