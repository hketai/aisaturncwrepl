module Saturn
  module Tools
    class HandoffAgent < Saturn::ToolBase
      private
      
      def configure_tool
        @name = 'handoff_to_human'
        @description = 'Transfer the conversation to a human agent when the AI cannot help or when explicitly requested'
        @parameters = {
          type: 'object',
          properties: {
            reason: {
              type: 'string',
              description: 'The reason for handing off to a human agent'
            }
          },
          required: ['reason']
        }
      end
      
      public
      
      def execute(arguments)
        reason = arguments['reason'] || 'User requested human assistance'
        
        {
          success: true,
          action: 'handoff_requested',
          reason: reason,
          message: 'This conversation will be transferred to a human agent.',
          timestamp: Time.current.iso8601
        }.to_json
      end
    end
  end
end
