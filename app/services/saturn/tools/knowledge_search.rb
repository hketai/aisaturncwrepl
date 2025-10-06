module Saturn
  module Tools
    class KnowledgeSearch < Saturn::ToolBase
      private
      
      def configure_tool
        @name = 'search_knowledge_base'
        @description = 'Search the knowledge base for relevant information to answer user questions'
        @parameters = {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'The search query to find relevant information'
            }
          },
          required: ['query']
        }
      end
      
      public
      
      def execute(arguments)
        query = arguments['query']
        return { error: 'No query provided', results: [] }.to_json if query.blank?
        
        results = search_knowledge(query)
        format_results(results, query).to_json
      end
      
      private
      
      def search_knowledge(query)
        Saturn::KnowledgeSource
          .for_agent(agent_profile.id)
          .where('title ILIKE ? OR content_text ILIKE ?', "%#{query}%", "%#{query}%")
          .limit(5)
      end
      
      def format_results(results, query)
        if results.any?
          {
            success: true,
            query: query,
            count: results.count,
            sources: results.map do |source|
              {
                id: source.id,
                title: source.title,
                content_preview: source.content_text&.truncate(200),
                source_url: source.source_url,
                source_type: source.source_type
              }
            end
          }
        else
          {
            success: true,
            query: query,
            count: 0,
            message: 'No relevant information found in the knowledge base.',
            sources: []
          }
        end
      end
    end
  end
end
