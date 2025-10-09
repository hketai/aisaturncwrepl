module Saturn
  class AutoRespondJob < ApplicationJob
    queue_as :default
    
    MAX_TRANSFER_DEPTH = 3 # Prevent infinite transfer loops
    
    def perform(message_id:, agent_profile_id:, account_id:, transfer_depth: 0)
      message = Message.find_by(id: message_id)
      return unless message
      
      # Prevent duplicate responses
      if already_responded?(message, agent_profile_id)
        Rails.logger.info("Saturn: Skipping duplicate response for message #{message_id}")
        return
      end
      
      agent_profile = Saturn::AgentProfile.find_by(id: agent_profile_id)
      return unless agent_profile&.active?
      
      account = Account.find_by(id: account_id)
      return unless account
      
      # Check AI conversation limit
      if account.ai_conversation_limit.present? && account.ai_conversation_count >= account.ai_conversation_limit
        Rails.logger.warn("Saturn: Account #{account_id} has reached AI conversation limit (#{account.ai_conversation_limit}), skipping auto-response")
        return
      end
      
      # Get OpenAI API key from account
      api_key = account.openai_api_key
      if api_key.blank?
        Rails.logger.warn("Saturn: No OpenAI API key for account #{account_id}, skipping auto-response")
        return
      end
      
      # Build conversation context
      context = build_context(message)
      
      # Generate response using Orchestrator
      orchestrator = Saturn::Orchestrator.new(
        agent_profile: agent_profile,
        api_key: api_key
      )
      
      result = orchestrator.process(message.content, context: context)
      
      # Handle result (including actions)
      if result[:success]
        process_agent_result(message, result, agent_profile, account, api_key, transfer_depth)
      else
        Rails.logger.error("Saturn auto-respond failed: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Saturn::AutoRespondJob error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
    
    private
    
    def build_context(message)
      conversation = message.conversation
      contact = conversation.contact
      inbox = conversation.inbox
      
      {
        conversation_id: conversation.display_id,
        contact_name: contact.name,
        contact_email: contact.email,
        inbox_name: inbox.name,
        inbox_type: inbox.channel_type,
        previous_messages: fetch_recent_messages(conversation)
      }
    end
    
    def fetch_recent_messages(conversation)
      conversation.messages
        .where.not(message_type: :activity)
        .where(private: false)
        .order(created_at: :desc)
        .limit(5)
        .reverse
        .map do |msg|
          {
            role: msg.outgoing? ? 'assistant' : 'user',
            content: msg.content,
            created_at: msg.created_at.iso8601
          }
        end
    end
    
    def already_responded?(message, agent_profile_id)
      conversation = message.conversation
      
      # Check if Saturn already responded to this message
      conversation.messages
        .where(message_type: :outgoing)
        .where("content_attributes->>'saturn_agent_id' = ?", agent_profile_id.to_s)
        .where('created_at > ?', message.created_at)
        .exists?
    end
    
    def handle_handoff(message, result)
      conversation = message.conversation
      team_id = result[:team_id]
      
      # Set conversation to pending status (waiting for human)
      conversation.update!(status: :pending, team_id: team_id)
      
      # Send handoff message to customer
      create_info_message(message, result[:message], :handoff)
      
      # Create internal note for team
      create_internal_note(message, result[:note_for_agent])
      
      Rails.logger.info("Saturn: Handed off conversation #{conversation.id} to team #{team_id}. Reason: #{result[:reason]}")
    end
    
    def handle_agent_transfer(message, result, account, api_key, depth = 0)
      transfer_agent_id = result[:transfer_to_agent_id]
      transfer_agent = Saturn::AgentProfile.find_by(id: transfer_agent_id)
      
      unless transfer_agent&.active?
        Rails.logger.error("Saturn: Transfer agent #{transfer_agent_id} not found or not active")
        return
      end
      
      # Send transfer message to customer
      create_info_message(message, result[:message], :transfer)
      
      # Create internal note
      create_internal_note(message, result[:note])
      
      # Update conversation to track current agent
      conversation = message.conversation
      conversation.update!(
        custom_attributes: (conversation.custom_attributes || {}).merge(
          'current_saturn_agent_id' => transfer_agent_id,
          'transfer_depth' => depth
        )
      )
      
      # Continue conversation with new agent
      context = build_context(message)
      orchestrator = Saturn::Orchestrator.new(
        agent_profile: transfer_agent,
        api_key: api_key
      )
      
      new_result = orchestrator.process(message.content, context: context)
      
      # Handle result recursively (new agent might also handoff/transfer)
      if new_result[:success]
        process_agent_result(message, new_result, transfer_agent, account, api_key, depth)
      end
      
      Rails.logger.info("Saturn: Transferred conversation #{conversation.id} to agent #{transfer_agent.name} (depth: #{depth})")
    end
    
    def process_agent_result(message, result, agent_profile, account, api_key, depth = 0)
      # Check transfer depth to prevent infinite loops
      if depth >= MAX_TRANSFER_DEPTH
        Rails.logger.error("Saturn: Max transfer depth (#{MAX_TRANSFER_DEPTH}) reached. Preventing infinite loop.")
        create_info_message(message, "Üzgünüm, teknik bir sorun oluştu. Lütfen bir temsilciyle görüşün.", :error)
        return
      end
      
      case result[:action]
      when 'handoff_requested'
        handle_handoff(message, result)
      when 'agent_transfer_requested'
        handle_agent_transfer(message, result, account, api_key, depth + 1)
      else
        # Normal response
        if result[:response].present?
          create_response_message(message, result[:response], agent_profile)
          account.increment_ai_conversation_count!
        end
      end
    end
    
    def create_info_message(original_message, content, message_type)
      conversation = original_message.conversation
      inbox = conversation.inbox
      
      sender = inbox.members.first || inbox.account.users.where(account_users: { role: :administrator }).first
      
      return unless sender
      
      Message.create!(
        account_id: conversation.account_id,
        inbox_id: conversation.inbox_id,
        conversation_id: conversation.id,
        message_type: :outgoing,
        content: content,
        sender: sender,
        private: false,
        content_attributes: {
          automated_response: true,
          transfer_type: message_type.to_s
        }
      )
    end
    
    def create_internal_note(original_message, content)
      conversation = original_message.conversation
      inbox = conversation.inbox
      
      sender = inbox.members.first || inbox.account.users.where(account_users: { role: :administrator }).first
      
      return unless sender
      
      Message.create!(
        account_id: conversation.account_id,
        inbox_id: conversation.inbox_id,
        conversation_id: conversation.id,
        message_type: :outgoing,
        content: content,
        sender: sender,
        private: true,
        content_attributes: {
          automated_note: true
        }
      )
    end
    
    def create_response_message(original_message, response_content, agent_profile)
      conversation = original_message.conversation
      inbox = conversation.inbox
      
      # Find a sender: prefer assigned agent, fallback to first inbox member, then admin
      sender = conversation.assignee || 
               inbox.members.first || 
               inbox.account.users.where(account_users: { role: :administrator }).first
      
      unless sender
        Rails.logger.error("Saturn: No suitable sender found for conversation #{conversation.id}")
        return
      end
      
      # Create message directly (MessageBuilder strips content_attributes)
      message = Message.create!(
        account_id: conversation.account_id,
        inbox_id: conversation.inbox_id,
        conversation_id: conversation.id,
        message_type: :outgoing,
        content: response_content,
        sender: sender,
        private: false,
        content_attributes: {
          saturn_agent_id: agent_profile.id.to_s,
          saturn_agent_name: agent_profile.name,
          automated_response: true
        }
      )
      
      Rails.logger.info("Saturn: Created auto-response message #{message.id} for conversation #{conversation.id}")
      message
    end
  end
end
