require 'openai'

module Saturn
  class LlmService
    attr_reader :client, :model, :temperature
    
    def initialize(api_key: nil, model: 'gpt-4o-mini', temperature: 0.7)
      @api_key = api_key || ENV['OPENAI_API_KEY']
      
      raise ArgumentError, 'OpenAI API key is required' if @api_key.blank?
      
      @model = model
      @temperature = temperature
      @client = OpenAI::Client.new(access_token: @api_key)
    end
    
    def generate_completion(messages, tools: [])
      params = {
        model: @model,
        messages: messages,
        temperature: @temperature
      }
      
      params[:tools] = tools if tools.any?
      params[:tool_choice] = 'auto' if tools.any?
      
      response = @client.chat(parameters: params)
      parse_response(response)
    rescue StandardError => e
      Rails.logger.error("Saturn LLM Error: #{e.message}")
      { error: e.message, success: false }
    end
    
    def generate_embedding(text)
      return { success: false, error: 'Text cannot be empty' } if text.blank?
      
      response = @client.embeddings(
        parameters: {
          model: 'text-embedding-3-small',
          input: text
        }
      )
      
      embedding = response.dig('data', 0, 'embedding')
      
      if embedding
        { success: true, embedding: embedding }
      else
        { success: false, error: 'No embedding returned from API' }
      end
    rescue StandardError => e
      Rails.logger.error("Saturn Embedding Error: #{e.message}")
      { success: false, error: e.message }
    end
    
    private
    
    def parse_response(response)
      choice = response.dig('choices', 0)
      message = choice['message']
      
      if message['tool_calls']
        {
          success: true,
          tool_call: message['tool_calls'].first,
          content: nil
        }
      else
        {
          success: true,
          content: message['content'],
          tool_call: nil
        }
      end
    end
  end
end
