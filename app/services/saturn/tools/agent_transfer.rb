module Saturn
  module Tools
    class AgentTransfer < Saturn::ToolBase
      private
      
      def configure_tool
        @name = 'transfer_to_agent'
        @description = 'Transfer the conversation to another AI agent with different expertise when the current agent cannot fully help'
        @parameters = {
          type: 'object',
          properties: {
            reason: {
              type: 'string',
              description: 'The reason for transferring to another AI agent'
            }
          },
          required: ['reason']
        }
      end
      
      public
      
      def execute(arguments)
        reason = arguments['reason'] || 'User needs different expertise'
        
        # Check if agent transfer is enabled
        unless @agent_profile.transfer_enabled?
          return {
            success: false,
            error: 'Agent transfer is not enabled',
            message: 'This agent cannot transfer conversations to other agents.'
          }.to_json
        end
        
        # Check if transfer agent is configured
        unless @agent_profile.transfer_agent_id.present?
          return {
            success: false,
            error: 'No transfer agent configured',
            message: 'No agent has been configured to receive transfers from this agent.'
          }.to_json
        end
        
        # Get the transfer agent details
        transfer_agent = Saturn::AgentProfile.find_by(id: @agent_profile.transfer_agent_id)
        
        unless transfer_agent&.active?
          return {
            success: false,
            error: 'Transfer agent not available',
            message: 'The configured transfer agent is not active or not found.'
          }.to_json
        end
        
        {
          success: true,
          action: 'agent_transfer_requested',
          reason: reason,
          transfer_to_agent_id: transfer_agent.id,
          transfer_to_agent_name: transfer_agent.name,
          message: "#{transfer_agent.name} adlı AI asistanına bağlanıyorsunuz...",
          note: "#{@agent_profile.name} tarafından transfer edildi. Sebep: #{reason}",
          timestamp: Time.current.iso8601
        }.to_json
      end
    end
  end
end
