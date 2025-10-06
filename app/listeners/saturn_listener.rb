class SaturnListener < BaseListener
  def message_created(event)
    message = event.data[:message]
    
    return if should_ignore_message?(message)
    
    conversation = message.conversation
    inbox = conversation.inbox
    
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
