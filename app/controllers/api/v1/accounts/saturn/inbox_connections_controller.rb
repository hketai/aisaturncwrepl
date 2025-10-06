class Api::V1::Accounts::Saturn::InboxConnectionsController < Api::V1::Accounts::Saturn::BaseController
  before_action :set_agent_profile
  
  def index
    @inbox_connections = @agent_profile.inbox_connections.includes(:inbox)
  end
  
  def create
    inbox = Current.account.inboxes.find(params[:inbox_id])
    @inbox_connection = @agent_profile.inbox_connections.create!(
      inbox: inbox,
      auto_respond: params[:auto_respond] || false,
      connection_settings: params[:connection_settings] || {}
    )
  end
  
  def destroy
    inbox = Current.account.inboxes.find(params[:inbox_id])
    connection = @agent_profile.inbox_connections.find_by!(inbox: inbox)
    connection.destroy!
    head :no_content
  end
  
  private
  
  def set_agent_profile
    @agent_profile = Current.account.saturn_agent_profiles.find(params[:agent_id])
  end
end
