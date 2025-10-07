# frozen_string_literal: true

module RubyLLM
  module Providers
    module OpenAI
      # Embeddings methods of the OpenAI API integration
      module Embeddings
        module_function

        def embedding_url(...)
          'embeddings'
        end

        def render_embedding_payload(text, model:, dimensions:)
          {
            model: model,
            input: text,
            dimensions: dimensions
          }.compact
        end

        def parse_embedding_response(response, model:, text:)
          data = response.body
          input_tokens = data.dig('usage', 'prompt_tokens') || 0
          vectors = data['data'].map { |d| d['embedding'] }

          # If we only got one embedding AND the input was a single string (not an array),
          # return it as a single vector
          vectors = vectors.first if vectors.length == 1 && !text.is_a?(Array)

          Embedding.new(vectors:, model:, input_tokens:)
        end
      end
    end
  end
end
