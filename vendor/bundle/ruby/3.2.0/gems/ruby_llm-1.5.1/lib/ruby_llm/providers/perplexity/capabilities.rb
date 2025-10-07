# frozen_string_literal: true

module RubyLLM
  module Providers
    module Perplexity
      # Determines capabilities and pricing for Perplexity models
      module Capabilities
        module_function

        # Returns the context window size for the given model ID
        # @param model_id [String] the model identifier
        # @return [Integer] the context window size in tokens
        def context_window_for(model_id)
          case model_id
          when /sonar-pro/ then 200_000
          else 128_000
          end
        end

        # Returns the maximum number of tokens that can be generated
        # @param model_id [String] the model identifier
        # @return [Integer] the maximum number of tokens
        def max_tokens_for(model_id)
          case model_id
          when /sonar-(?:pro|reasoning-pro)/ then 8_192
          else 4_096
          end
        end

        # Returns the price per million tokens for input
        # @param model_id [String] the model identifier
        # @return [Float] the price per million tokens in USD
        def input_price_for(model_id)
          PRICES.dig(model_family(model_id), :input) || 1.0
        end

        # Returns the price per million tokens for output
        # @param model_id [String] the model identifier
        # @return [Float] the price per million tokens in USD
        def output_price_for(model_id)
          PRICES.dig(model_family(model_id), :output) || 1.0
        end

        # Determines if the model supports vision capabilities
        # @param model_id [String] the model identifier
        # @return [Boolean] true if the model supports vision
        def supports_vision?(model_id)
          case model_id
          when /sonar-reasoning-pro/, /sonar-reasoning/, /sonar-pro/, /sonar/ then true
          else false
          end
        end

        # Determines if the model supports function calling
        # @param model_id [String] the model identifier
        # @return [Boolean] true if the model supports functions
        def supports_functions?(_model_id)
          false
        end

        # Determines if the model supports JSON mode
        def supports_json_mode?(_model_id)
          true
        end

        # Formats the model ID into a human-readable display name
        # @param model_id [String] the model identifier
        # @return [String] the formatted display name
        def format_display_name(model_id)
          case model_id
          when 'sonar' then 'Sonar'
          when 'sonar-pro' then 'Sonar Pro'
          when 'sonar-reasoning' then 'Sonar Reasoning'
          when 'sonar-reasoning-pro' then 'Sonar Reasoning Pro'
          when 'sonar-deep-research' then 'Sonar Deep Research'
          else
            model_id.split('-')
                    .map(&:capitalize)
                    .join(' ')
          end
        end

        # Returns the model type
        # @param model_id [String] the model identifier
        # @return [String] the model type (e.g., 'chat')
        def model_type(_model_id)
          'chat'
        end

        # Returns the model family
        # @param model_id [String] the model identifier
        # @return [Symbol] the model family
        def model_family(model_id)
          case model_id
          when 'sonar' then :sonar
          when 'sonar-pro' then :sonar_pro
          when 'sonar-reasoning' then :sonar_reasoning
          when 'sonar-reasoning-pro' then :sonar_reasoning_pro
          when 'sonar-deep-research' then :sonar_deep_research
          else :unknown
          end
        end

        def modalities_for(_model_id)
          {
            input: ['text'],
            output: ['text']
          }
        end

        def capabilities_for(model_id)
          capabilities = %w[streaming json_mode]
          capabilities << 'vision' if supports_vision?(model_id)
          capabilities
        end

        def pricing_for(model_id)
          family = model_family(model_id)
          prices = PRICES.fetch(family, { input: 1.0, output: 1.0 })

          standard_pricing = {
            input_per_million: prices[:input],
            output_per_million: prices[:output]
          }

          # Add special pricing if available
          standard_pricing[:citation_per_million] = prices[:citation] if prices[:citation]
          standard_pricing[:reasoning_per_million] = prices[:reasoning] if prices[:reasoning]
          standard_pricing[:search_per_thousand] = prices[:search_queries] if prices[:search_queries]

          {
            text_tokens: {
              standard: standard_pricing
            }
          }
        end

        # Pricing information for Perplexity models (USD per 1M tokens)
        PRICES = {
          sonar: {
            input: 1.0,
            output: 1.0
          },
          sonar_pro: {
            input: 3.0,
            output: 15.0
          },
          sonar_reasoning: {
            input: 1.0,
            output: 5.0
          },
          sonar_reasoning_pro: {
            input: 2.0,
            output: 8.0
          },
          sonar_deep_research: {
            input: 2.0,
            output: 8.0,
            citation: 2.0,
            reasoning: 3.0,
            search_queries: 5.0
          }
        }.freeze
      end
    end
  end
end
