# frozen_string_literal: true

module RubyLLM
  module Providers
    module Gemini
      # Media handling methods for the Gemini API integration
      module Media
        module_function

        def format_content(content)
          # Convert Hash/Array back to JSON string for API
          return [format_text(content.to_json)] if content.is_a?(Hash) || content.is_a?(Array)
          return [format_text(content)] unless content.is_a?(Content)

          parts = []
          parts << format_text(content.text) if content.text

          content.attachments.each do |attachment|
            case attachment.type
            when :text
              parts << format_text_file(attachment)
            when :unknown
              raise UnsupportedAttachmentError, attachment.mime_type
            else
              parts << format_attachment(attachment)
            end
          end

          parts
        end

        def format_attachment(attachment)
          {
            inline_data: {
              mime_type: attachment.mime_type,
              data: attachment.encoded
            }
          }
        end

        def format_text_file(text_file)
          {
            text: Utils.format_text_file_for_llm(text_file)
          }
        end

        def format_text(text)
          {
            text: text
          }
        end
      end
    end
  end
end
