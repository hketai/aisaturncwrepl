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
            },
            detected_intent: {
              type: 'string',
              description: 'Optional: The detected customer intent (e.g., "billing question", "technical support")'
            }
          },
          required: ['reason']
        }
      end
      
      public
      
      def execute(arguments)
        reason = arguments['reason'] || 'User needs different expertise'
        detected_intent = arguments['detected_intent']&.strip&.downcase
        
        # Check if agent transfer is enabled
        unless @agent_profile.transfer_enabled?
          return {
            success: false,
            error: 'Agent transfer is not enabled',
            message: 'This agent cannot transfer conversations to other agents.'
          }.to_json
        end
        
        # Determine target agent based on intent routing
        target_agent = determine_target_agent(detected_intent)
        
        unless target_agent
          return {
            success: false,
            error: 'No transfer agent configured or available',
            message: 'No agent has been configured to receive transfers from this agent.'
          }.to_json
        end
        
        {
          success: true,
          action: 'agent_transfer_requested',
          reason: reason,
          detected_intent: detected_intent,
          transfer_to_agent_id: target_agent.id,
          transfer_to_agent_name: target_agent.name,
          message: "#{target_agent.name} adlı AI asistanına bağlanıyorsunuz...",
          note: "#{@agent_profile.name} tarafından transfer edildi. Sebep: #{reason}#{detected_intent.present? ? " | Intent: #{detected_intent}" : ""}",
          timestamp: Time.current.iso8601
        }.to_json
      end
      
      private
      
      def determine_target_agent(detected_intent)
        # Scenario 3: Intent-based routing to another agent
        if detected_intent.present? && @agent_profile.intent_agent_mappings.present?
          mapping = @agent_profile.intent_agent_mappings.find do |m|
            m['intent']&.downcase == detected_intent
          end
          
          if mapping && mapping['agent_id'].present?
            agent = Saturn::AgentProfile.find_by(id: mapping['agent_id'])
            return agent if agent&.enabled?
          end
        end
        
        # Fallback to default transfer agent (if configured)
        if @agent_profile.transfer_agent_id.present?
          agent = Saturn::AgentProfile.find_by(id: @agent_profile.transfer_agent_id)
          return agent if agent&.enabled?
        end
        
        nil
      end
    end
  end
end
