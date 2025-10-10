class AddEnabledToSaturnAgentProfiles < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:saturn_agent_profiles, :enabled)
      add_column :saturn_agent_profiles, :enabled, :boolean, default: true, null: false
    end
  end
end
