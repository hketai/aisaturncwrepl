class AddAiConversationLimitsToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :ai_conversation_limit, :integer, default: nil, comment: 'Maximum AI conversations allowed per month (nil = unlimited)'
    add_column :accounts, :ai_conversation_count, :integer, default: 0, comment: 'Current AI conversation count this month'
    add_column :accounts, :ai_limit_reset_at, :datetime, comment: 'When the AI conversation counter was last reset'
  end
end
