class Saturn::KnowledgeSource < ApplicationRecord
  self.table_name = 'saturn_knowledge_sources'
  
  belongs_to :agent_profile, class_name: 'Saturn::AgentProfile'
  belongs_to :account
  has_many :auto_replies, 
           class_name: 'Saturn::AutoReply', 
           foreign_key: :knowledge_source_id, 
           dependent: :nullify
  
  validates :title, presence: true
  validates :agent_profile_id, presence: true
  validates :account_id, presence: true
  validates :source_type, inclusion: { in: %w[document url text faq] }
  
  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :for_agent, ->(agent_id) { where(agent_profile_id: agent_id) }
  scope :by_type, ->(type) { where(source_type: type) }
  scope :ordered, -> { order(created_at: :desc) }
  
  before_validation :set_account_from_agent
  
  private
  
  def set_account_from_agent
    self.account_id ||= agent_profile&.account_id
  end
end
