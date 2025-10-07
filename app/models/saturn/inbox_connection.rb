class Saturn::InboxConnection < ApplicationRecord
  self.table_name = 'saturn_inbox_connections'
  
  belongs_to :agent_profile, class_name: 'Saturn::AgentProfile'
  belongs_to :inbox
  
  validates :agent_profile_id, presence: true
  validates :inbox_id, presence: true
  validates :inbox_id, uniqueness: { scope: :agent_profile_id }
  
  scope :auto_respond_enabled, -> { where(auto_respond: true) }
  scope :for_agent, ->(agent_id) { where(agent_profile_id: agent_id) }
  scope :for_inbox, ->(inbox_id) { where(inbox_id: inbox_id) }
  
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy
  
  def push_event_data
    {
      id: id,
      agent_profile_id: agent_profile_id,
      inbox: inbox.as_json,
      auto_respond: auto_respond,
      connection_settings: connection_settings,
      created_at: created_at,
      updated_at: updated_at
    }
  end
  
  private
  
  def broadcast_create
    broadcast_to_account('saturn_inbox_connection.created', push_event_data)
  end
  
  def broadcast_update
    broadcast_to_account('saturn_inbox_connection.updated', push_event_data)
  end
  
  def broadcast_destroy
    broadcast_to_account('saturn_inbox_connection.deleted', { id: id, agent_profile_id: agent_profile_id, inbox_id: inbox_id })
  end
  
  def broadcast_to_account(event, data)
    account_id = agent_profile.account_id
    ActionCable.server.broadcast(
      "account_#{account_id}",
      { event: event, data: data }
    )
  end
end
