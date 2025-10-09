class RemoveActiveFromSaturnAgentProfiles < ActiveRecord::Migration[7.1]
  def change
    # Column already removed via SQL - this migration is for schema tracking only
    remove_column :saturn_agent_profiles, :active, :boolean, default: true if column_exists?(:saturn_agent_profiles, :active)
  end
end
