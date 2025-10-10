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
            },
            detected_intent: {
              type: 'string',
              description: 'Optional: The detected customer intent (e.g., "refund request", "technical support")'
            }
          },
          required: ['reason']
        }
      end
      
      public
      
      def execute(arguments)
        reason = arguments['reason'] || 'User requested human assistance'
        detected_intent = arguments['detected_intent']&.strip&.downcase
        
        # Check if handoff is enabled for this agent
        unless @agent_profile.handoff_enabled?
          return {
            success: false,
            error: 'Handoff is not enabled for this agent',
            message: 'This agent cannot transfer conversations to human agents.'
          }.to_json
        end
        
        # Determine target team based on intent routing
        target_team_id = determine_target_team(detected_intent)
        
        unless target_team_id.present?
          return {
            success: false,
            error: 'No handoff team configured',
            message: 'No team has been configured to receive handoffs from this agent.'
          }.to_json
        end
        
        # Get team name for response
        team = Team.find_by(id: target_team_id)
        team_name = team&.name || 'support team'
        
        {
          success: true,
          action: 'handoff_requested',
          reason: reason,
          detected_intent: detected_intent,
          team_id: target_team_id,
          team_name: team_name,
          note_for_agent: "AI tarafından #{team_name} ekibine transfer edildi. Sebep: #{reason}#{detected_intent.present? ? " | Intent: #{detected_intent}" : ""}",
          timestamp: Time.current.iso8601
        }.to_json
      end
      
      private
      
      def determine_target_team(detected_intent)
        # Scenario 2: Intent-based routing to team
        if detected_intent.present? && @agent_profile.intent_routing_enabled? && @agent_profile.intent_team_mappings.present?
          mapping = @agent_profile.intent_team_mappings.find do |m|
            m['intent']&.downcase == detected_intent
          end
          
          return mapping['team_id'] if mapping && mapping['team_id'].present?
        end
        
        # Scenario 1: Fallback to default team (when agent can't answer)
        @agent_profile.handoff_team_id
      end
    end
  end
end
