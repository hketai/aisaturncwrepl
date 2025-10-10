class Whatsapp::Providers::WhatsappWebService
  MICROSERVICE_BASE_URL = ENV.fetch('WHATSAPP_WEB_SERVICE_URL', 'http://localhost:3001')

  def initialize(whatsapp_channel)
    @whatsapp_channel = whatsapp_channel
  end

  def send_message(phone_number, message)
    jid = format_jid(phone_number)
    
    response = http_client.post(
      "/channels/#{@whatsapp_channel.id}/messages/text",
      {
        to: jid,
        text: message
      }
    )

    handle_response(response)
  end

  def send_template(phone_number, template_info)
    send_message(phone_number, template_info[:body])
  end

  def send_attachment(phone_number, attachment)
    jid = format_jid(phone_number)
    media_type = detect_media_type(attachment.file_type)

    response = http_client.post(
      "/channels/#{@whatsapp_channel.id}/messages/media",
      {
        to: jid,
        url: attachment.download_url,
        caption: attachment.file_name,
        mediaType: media_type
      }
    )

    handle_response(response)
  end

  def connect
    webhook_url = "#{ENV.fetch('RAILS_BASE_URL', 'http://localhost:5000')}/webhooks/whatsapp_web/#{@whatsapp_channel.id}"
    
    response = http_client.post(
      "/channels/#{@whatsapp_channel.id}/connect",
      { webhookUrl: webhook_url }
    )

    result = handle_response(response)
    
    @whatsapp_channel.provider_config['status'] = 'initiating'
    @whatsapp_channel.provider_config['qr_code'] = result[:qr] if result[:qr].present?
    @whatsapp_channel.save!

    result
  end

  def disconnect
    response = http_client.post("/channels/#{@whatsapp_channel.id}/disconnect", {})
    handle_response(response)
  end

  def status
    response = http_client.get("/channels/#{@whatsapp_channel.id}/status")
    handle_response(response)
  end

  def sync_templates
    []
  end

  def validate_provider_config?
    true
  end

  def api_headers
    {}
  end

  private

  def http_client
    @http_client ||= begin
      conn = Faraday.new(url: MICROSERVICE_BASE_URL) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        faraday.options.timeout = 30
        faraday.options.open_timeout = 10
        faraday.headers['X-Whatsapp-Secret'] = ENV.fetch('WHATSAPP_WEB_SECRET', 'development-secret-change-in-production')
      end
      conn
    end
  end

  def handle_response(response)
    if response.success?
      response.body.with_indifferent_access
    else
      raise "WhatsApp Web service error: #{response.status} - #{response.body}"
    end
  rescue Faraday::Error => e
    Rails.logger.error("WhatsApp Web service connection error: #{e.message}")
    raise "Failed to connect to WhatsApp Web service: #{e.message}"
  end

  def format_jid(phone_number)
    cleaned = phone_number.gsub(/[^0-9]/, '')
    "#{cleaned}@s.whatsapp.net"
  end

  def detect_media_type(file_type)
    case file_type
    when /image/
      'image'
    when /video/
      'video'
    when /audio/
      'audio'
    else
      'document'
    end
  end
end
