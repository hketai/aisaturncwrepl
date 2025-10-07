class Saturn::KnowledgeSource < ApplicationRecord
  self.table_name = 'saturn_knowledge_sources'
  
  belongs_to :agent_profile, class_name: 'Saturn::AgentProfile'
  belongs_to :account
  has_many :auto_replies, 
           class_name: 'Saturn::AutoReply', 
           foreign_key: :knowledge_source_id, 
           dependent: :destroy
  
  validates :title, presence: true
  validates :agent_profile_id, presence: true
  validates :account_id, presence: true
  validates :source_type, inclusion: { in: %w[document url text faq] }
  
  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :for_agent, ->(agent_id) { where(agent_profile_id: agent_id) }
  scope :by_type, ->(type) { where(source_type: type) }
  scope :ordered, -> { order(created_at: :desc) }
  
  before_validation :set_account_from_agent
  
  after_create_commit :broadcast_create
  after_update_commit :broadcast_update
  after_destroy_commit :broadcast_destroy
  
  def push_event_data
    {
      id: id,
      agent_profile_id: agent_profile_id,
      title: title,
      content_text: content_text,
      source_type: source_type,
      source_url: source_url,
      created_at: created_at,
      updated_at: updated_at
    }
  end
  
  private
  
  def set_account_from_agent
    self.account_id ||= agent_profile&.account_id
  end
  
  def broadcast_create
    broadcast_to_account('saturn_knowledge.created', push_event_data)
  end
  
  def broadcast_update
    broadcast_to_account('saturn_knowledge.updated', push_event_data)
  end
  
  def broadcast_destroy
    broadcast_to_account('saturn_knowledge.deleted', { id: id, agent_profile_id: agent_profile_id })
  end
  
  def broadcast_to_account(event, data)
    ActionCable.server.broadcast(
      "account_#{account_id}",
      { event: event, data: data }
    )
  end
end
