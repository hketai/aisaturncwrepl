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
        
        # Check if handoff is enabled for this agent
        unless @agent_profile.handoff_enabled?
          return {
            success: false,
            error: 'Handoff is not enabled for this agent',
            message: 'This agent cannot transfer conversations to human agents.'
          }.to_json
        end
        
        # Check if handoff team is configured
        unless @agent_profile.handoff_team_id.present?
          return {
            success: false,
            error: 'No handoff team configured',
            message: 'No team has been configured to receive handoffs from this agent.'
          }.to_json
        end
        
        {
          success: true,
          action: 'handoff_requested',
          reason: reason,
          team_id: @agent_profile.handoff_team_id,
          message: 'Bu konuşma bir temsilciye aktarılıyor...',
          note_for_agent: "AI tarafından transfer edildi. Sebep: #{reason}",
          timestamp: Time.current.iso8601
        }.to_json
      end
    end
  end
end
