class Webhooks::WhatsappWebController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false
  skip_before_action :authenticate_user!, raise: false
  before_action :verify_signature

  def create
    channel = Channel::Whatsapp.find(params[:channel_id])
    
    case webhook_params[:event]
    when 'message.received'
      handle_incoming_message(channel, webhook_params[:message])
    when 'connection.open'
      handle_connection_open(channel)
    when 'connection.closed'
      handle_connection_closed(channel, webhook_params[:should_reconnect])
    when 'qr.generated'
      handle_qr_generated(channel, webhook_params[:qr_code])
    end

    head :ok
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue StandardError => e
    Rails.logger.error("WhatsApp Web webhook error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    head :internal_server_error
  end

  private

  def verify_signature
    signature = request.headers['X-Whatsapp-Signature']
    
    # Reject missing or empty signature immediately
    if signature.blank?
      Rails.logger.warn("Missing WhatsApp webhook signature from #{request.remote_ip}")
      head :unauthorized
      return
    end
    
    shared_secret = ENV.fetch('WHATSAPP_WEB_SECRET', 'development-secret-change-in-production')
    payload = request.raw_post
    expected_signature = OpenSSL::HMAC.hexdigest('SHA256', shared_secret, payload)
    
    # Verify length matches before secure_compare to prevent ArgumentError (DoS risk)
    if signature.length != expected_signature.length
      Rails.logger.warn("Invalid WhatsApp webhook signature length from #{request.remote_ip}")
      head :unauthorized
      return
    end
    
    unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
      Rails.logger.warn("Invalid WhatsApp webhook signature from #{request.remote_ip}")
      head :unauthorized
      return
    end
  end

  def webhook_params
    params.permit(:event, :channel_id, :should_reconnect, :qr_code, message: [:id, :from, :timestamp, :text, :media_type])
  end

  def handle_incoming_message(channel, message_data)
    inbox = channel.inbox
    contact_inbox = create_or_update_contact_inbox(inbox, message_data[:from])

    conversation = create_or_get_conversation(contact_inbox, inbox)

    create_message(conversation, message_data)

    Rails.logger.info("WhatsApp Web message received: #{message_data[:id]}")
  end

  def handle_connection_open(channel)
    channel.provider_config['status'] = 'connected'
    channel.provider_config['connected_at'] = Time.current
    channel.provider_config.delete('qr_code')
    channel.save!

    Rails.logger.info("WhatsApp Web connected: channel_#{channel.id}")
  end

  def handle_connection_closed(channel, should_reconnect)
    channel.provider_config['status'] = 'disconnected'
    channel.provider_config['disconnected_at'] = Time.current
    channel.save!

    Rails.logger.warn("WhatsApp Web disconnected: channel_#{channel.id}, reconnect: #{should_reconnect}")
  end

  def handle_qr_generated(channel, qr_code)
    channel.provider_config['qr_code'] = qr_code
    channel.provider_config['status'] = 'connecting'
    channel.save!

    Rails.logger.info("WhatsApp Web QR generated: channel_#{channel.id}")
  end

  def create_or_update_contact_inbox(inbox, jid)
    phone_number = extract_phone_number(jid)
    source_id = jid.split('@').first
    
    contact = inbox.account.contacts.find_or_create_by!(phone_number: phone_number) do |c|
      c.name = phone_number
    end

    inbox.contact_inboxes.find_or_create_by!(contact: contact) do |ci|
      ci.source_id = source_id
    end
  end

  def create_or_get_conversation(contact_inbox, inbox)
    Conversation.find_or_create_by!(
      account: inbox.account,
      inbox: inbox,
      contact: contact_inbox.contact
    ) do |conversation|
      conversation.contact_inbox = contact_inbox
      conversation.status = :pending
    end
  end

  def create_message(conversation, message_data)
    return if conversation.messages.exists?(source_id: message_data[:id])

    message_params = {
      account: conversation.account,
      inbox: conversation.inbox,
      conversation: conversation,
      contact: conversation.contact,
      sender: conversation.contact,
      message_type: :incoming,
      content: message_data[:text],
      source_id: message_data[:id],
      created_at: Time.zone.at(message_data[:timestamp].to_i)
    }

    conversation.messages.create!(message_params)
  end

  def extract_phone_number(jid)
    number = jid.split('@').first
    number.start_with?('+') ? number : "+#{number}"
  end
end
