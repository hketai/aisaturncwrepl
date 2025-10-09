class SaturnListener < BaseListener
  def message_created(event)
    message = event.data[:message]
    
    return if should_ignore_message?(message)
    
    conversation = message.conversation
    inbox = conversation.inbox
    
    # Check if conversation has been transferred to a specific agent
    current_agent_id = conversation.custom_attributes&.dig('current_saturn_agent_id')
    transfer_depth = (conversation.custom_attributes&.dig('transfer_depth') || 0).to_i
    
    if current_agent_id.present?
      # Use the transferred agent
      agent_profile = Saturn::AgentProfile.find_by(id: current_agent_id, active: true)
      
      if agent_profile
        Saturn::AutoRespondJob.perform_later(
          message_id: message.id,
          agent_profile_id: agent_profile.id,
          account_id: conversation.account_id,
          transfer_depth: transfer_depth
        )
        return
      end
      # If transferred agent not found/active, fall back to inbox connection
    end
    
    # Find active Saturn agent connected to this inbox
    connection = Saturn::InboxConnection
      .joins(:agent_profile)
      .where(inbox_id: inbox.id, auto_respond: true)
      .where(saturn_agent_profiles: { active: true })
      .first
    
    return unless connection
    
    # Process message and generate response asynchronously
    Saturn::AutoRespondJob.perform_later(
      message_id: message.id,
      agent_profile_id: connection.agent_profile_id,
      account_id: conversation.account_id
    )
  end
  
  private
  
  def should_ignore_message?(message)
    # Ignore outgoing messages (from agents)
    return true if message.outgoing?
    
    # Ignore activity/system messages
    return true if message.activity?
    
    # Ignore private notes
    return true if message.private?
    
    # Ignore if message is from bot
    return true if message.content_type == 'input_select'
    
    false
  end
end
