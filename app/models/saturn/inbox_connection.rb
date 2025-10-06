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
end
