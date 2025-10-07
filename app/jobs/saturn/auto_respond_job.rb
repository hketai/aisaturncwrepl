module Saturn
  class AutoRespondJob < ApplicationJob
    queue_as :default
    
    def perform(message_id:, agent_profile_id:, account_id:)
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
      
      # Create response message if successful
      if result[:success] && result[:response].present?
        create_response_message(message, result[:response], agent_profile)
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
    
    def create_response_message(original_message, response_content, agent_profile)
      conversation = original_message.conversation
      inbox = conversation.inbox
      
      # Find a sender: prefer assigned agent, fallback to first inbox member, then bot user
      sender = conversation.assignee || 
               inbox.members.first || 
               inbox.account.users.where(account_users: { role: :administrator }).first
      
      unless sender
        Rails.logger.error("Saturn: No suitable sender found for conversation #{conversation.id}")
        return
      end
      
      # Create outgoing message from agent
      Messages::MessageBuilder.new(
        sender,
        conversation,
        {
          message_type: :outgoing,
          content: response_content,
          private: false,
          content_attributes: {
            saturn_agent_id: agent_profile.id.to_s,
            saturn_agent_name: agent_profile.name,
            automated_response: true
          }
        }
      ).perform
    end
  end
end
