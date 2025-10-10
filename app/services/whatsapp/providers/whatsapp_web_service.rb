class Whatsapp::Providers::WhatsappWebService < Whatsapp::Providers::BaseService
  def send_message(phone_number, message)
    @message = message
    
    socket = get_or_create_socket
    return unless socket&.connected?
    
    jid = format_jid(phone_number)
    
    if message.attachments.present?
      send_attachment_message(socket, jid, message)
    else
      send_text_message(socket, jid, message)
    end
  rescue StandardError => e
    Rails.logger.error "[WHATSAPP_WEB] Send message failed: #{e.message}"
    handle_error_message(e.message, message)
    nil
  end

  def send_template(_phone_number, _template_info, _message)
    Rails.logger.warn "[WHATSAPP_WEB] Templates not supported in WhatsApp Web"
    nil
  end

  def sync_templates
    whatsapp_channel.mark_message_templates_updated
  end

  def validate_provider_config?
    whatsapp_channel.provider_config.present?
  end

  def error_message(error)
    error.to_s
  end

  def api_headers
    {}
  end

  def media_url(media_id)
    nil
  end

  def generate_qr_code
    socket = get_or_create_socket
    qr_data = whatsapp_channel.provider_config['qr_code']
    
    return nil if qr_data.blank?
    
    require 'qrcode'
    qrcode = RQRCode::QRCode.new(qr_data)
    png = qrcode.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 300,
      border_modules: 4,
      module_px_size: 6
    )
    
    "data:image/png;base64,#{Base64.strict_encode64(png.to_s)}"
  end

  def connection_status
    whatsapp_channel.provider_config['connection_status'] || 'disconnected'
  end

  private

  def get_or_create_socket
    WhatsappWebConnectionManager.instance.get_socket(whatsapp_channel.id)
  end

  def format_jid(phone_number)
    clean_number = phone_number.gsub(/\D/, '')
    "#{clean_number}@s.whatsapp.net"
  end

  def send_text_message(socket, jid, message)
    response = socket.send_message(jid, message.outgoing_content)
    response['key']['id'] if response.present?
  end

  def send_attachment_message(socket, jid, message)
    attachment = message.attachments.first
    response = socket.send_attachment(jid, attachment, message.outgoing_content)
    response['key']['id'] if response.present?
  end

  def handle_error_message(error_msg, message)
    return if message.blank?
    
    message.external_error = error_msg
    message.status = :failed
    message.save!
  end
end
