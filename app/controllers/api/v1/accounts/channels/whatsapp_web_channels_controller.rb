class Api::V1::Accounts::Channels::WhatsappWebChannelsController < Api::V1::Accounts::BaseController
  before_action :set_channel, only: [:connect, :disconnect, :status, :qr_code]
  before_action :authorize_request

  def connect
    result = @channel.provider_service.connect
    
    render json: {
      status: result[:status],
      qr_code: result[:qr],
      message: 'WhatsApp Web connection initiated. Please scan the QR code.'
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def disconnect
    result = @channel.provider_service.disconnect
    
    render json: {
      status: result[:status],
      message: 'WhatsApp Web disconnected successfully'
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def status
    result = @channel.provider_service.status
    provider_config = @channel.provider_config || {}
    
    render json: {
      connected: result[:connected],
      authenticated: result[:authenticated],
      status: provider_config['status'],
      connected_at: provider_config['connected_at'],
      disconnected_at: provider_config['disconnected_at']
    }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def qr_code
    result = @channel.provider_service.qr_code
    
    if result[:qr_code].present?
      @channel.update(provider_config: @channel.provider_config.merge('qr_code' => result[:qr_code]))
      render json: { qr_code: result[:qr_code] }
    else
      render json: { error: 'QR code not available. Please initiate connection first.' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_channel
    @channel = Current.account.whatsapp_channels.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'WhatsApp channel not found' }, status: :not_found
  end

  def authorize_request
    authorize ::Inbox
  end
end
