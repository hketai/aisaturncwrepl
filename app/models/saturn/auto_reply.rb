class Saturn::AutoReply < ApplicationRecord
  self.table_name = 'saturn_auto_replies'
  
  belongs_to :agent_profile, class_name: 'Saturn::AgentProfile'
  belongs_to :knowledge_source, class_name: 'Saturn::KnowledgeSource', optional: true
  belongs_to :account
  
  validates :user_query, presence: true
  validates :agent_response, presence: true
  validates :agent_profile_id, presence: true
  validates :account_id, presence: true
  validates :confidence_score, 
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, 
            allow_nil: true
  
  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :for_agent, ->(agent_id) { where(agent_profile_id: agent_id) }
  scope :high_confidence, -> { where('confidence_score > ?', 0.7) }
  scope :ordered, -> { order(created_at: :desc) }
  
  before_validation :set_account_from_agent
  
  private
  
  def set_account_from_agent
    self.account_id ||= agent_profile&.account_id
  end
end
