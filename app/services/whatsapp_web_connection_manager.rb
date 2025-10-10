require 'singleton'

class WhatsappWebConnectionManager
  include Singleton

  def initialize
    @connections = {}
    @mutex = Mutex.new
  end

  def get_socket(channel_id)
    @mutex.synchronize do
      @connections[channel_id] ||= create_connection(channel_id)
    end
  end

  def disconnect(channel_id)
    @mutex.synchronize do
      socket = @connections[channel_id]
      socket&.disconnect
      @connections.delete(channel_id)
    end
  end

  def disconnect_all
    @mutex.synchronize do
      @connections.each_value(&:disconnect)
      @connections.clear
    end
  end

  private

  def create_connection(channel_id)
    channel = Channel::Whatsapp.find(channel_id)
    WhatsappWebSocket.new(channel)
  end
end
