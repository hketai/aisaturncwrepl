class AddOpenaiApiKeyToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :openai_api_key, :text
  end
end
