module Saturn
  class IntentDetector
    MAX_CONTEXT_LENGTH = 500  # Son mesajları sınırla (token tasarrufu)
    
    def initialize(api_key:, agent_profile:)
      @api_key = api_key
      @agent_profile = agent_profile
      @client = OpenAI::Client.new(access_token: @api_key)
    end
    
    def detect_intent(user_message:, conversation_context: nil)
      # Available intents from mappings
      available_intents = collect_available_intents
      
      return nil if available_intents.empty?
      
      # Build lightweight prompt (token-optimized)
      prompt = build_intent_prompt(user_message, available_intents, conversation_context)
      
      response = @client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',  # Faster and cheaper than gpt-4
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.3,  # Low temperature for consistent intent detection
          max_tokens: 50  # Very short response needed
        }
      )
      
      detected_intent = response.dig('choices', 0, 'message', 'content')&.strip&.downcase
      
      # Return only if it matches an available intent
      available_intents.find { |intent| intent.downcase == detected_intent }
    rescue => e
      Rails.logger.error("Intent detection error: #{e.message}")
      nil
    end
    
    private
    
    def collect_available_intents
      intents = []
      
      # Collect from team mappings
      if @agent_profile.intent_team_mappings.present?
        intents += @agent_profile.intent_team_mappings.map { |m| m['intent'] }.compact
      end
      
      # Collect from agent mappings
      if @agent_profile.intent_agent_mappings.present?
        intents += @agent_profile.intent_agent_mappings.map { |m| m['intent'] }.compact
      end
      
      intents.uniq
    end
    
    def build_intent_prompt(user_message, available_intents, context)
      # Token-optimized: Only last 500 chars of context
      context_str = context.to_s
      short_context = context_str.length > MAX_CONTEXT_LENGTH ? context_str[-MAX_CONTEXT_LENGTH..-1] : context_str
      
      <<~PROMPT
        Analyze this customer message and identify the PRIMARY intent from the list below.
        
        Customer message: "#{user_message}"
        #{short_context.present? ? "Recent context: #{short_context}" : ""}
        
        Available intents:
        #{available_intents.map { |i| "- #{i}" }.join("\n")}
        
        Rules:
        - Respond with ONLY the exact intent name (lowercase)
        - If no intent matches, respond with: none
        - Choose the MOST SPECIFIC intent that matches
        
        Intent:
      PROMPT
    end
  end
end
