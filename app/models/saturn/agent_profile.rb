class Saturn::AgentProfile < ApplicationRecord
  include Avatarable
  
  self.table_name = 'saturn_agent_profiles'
  
  belongs_to :account
  has_many :knowledge_sources, 
           class_name: 'Saturn::KnowledgeSource', 
           foreign_key: :agent_profile_id, 
           dependent: :destroy_async
  has_many :auto_replies, 
           class_name: 'Saturn::AutoReply', 
           foreign_key: :agent_profile_id, 
           dependent: :destroy_async
  has_many :inbox_connections, 
           class_name: 'Saturn::InboxConnection', 
           foreign_key: :agent_profile_id, 
           dependent: :destroy_async
  has_many :inboxes, through: :inbox_connections
  has_many :messages, as: :sender, dependent: :nullify
  
  validates :name, presence: true
  validates :account_id, presence: true
  validates :name, uniqueness: { scope: :account_id }
  validates :ai_temperature, 
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 2 }, 
            allow_nil: true
  
  scope :active, -> { where(active: true) }
  scope :for_account, ->(account_id) { where(account_id: account_id) }
  scope :ordered, -> { order(created_at: :desc) }
  
  store_accessor :configuration, :model_provider, :model_name, :max_tokens
  
  def available_name
    name
  end
  
  def push_event_data
    {
      id: id,
      name: name,
      avatar_url: avatar_url.presence || default_avatar_url,
      description: description,
      active: active,
      created_at: created_at,
      type: 'saturn_agent'
    }
  end
  
  def webhook_data
    push_event_data
  end
  
  private
  
  def default_avatar_url
    "#{ENV.fetch('FRONTEND_URL', nil)}/assets/images/dashboard/saturn/logo.svg"
  end
end
