class AddHandoffAndTransferToSaturnAgentProfiles < ActiveRecord::Migration[7.1]
  def change
    # Handoff settings (transfer to human team)
    unless column_exists?(:saturn_agent_profiles, :handoff_enabled)
      add_column :saturn_agent_profiles, :handoff_enabled, :boolean, default: false
    end
    
    unless column_exists?(:saturn_agent_profiles, :handoff_team_id)
      add_column :saturn_agent_profiles, :handoff_team_id, :bigint
      add_index :saturn_agent_profiles, :handoff_team_id
    end
    
    # Agent transfer settings (transfer to another AI agent)
    unless column_exists?(:saturn_agent_profiles, :transfer_enabled)
      add_column :saturn_agent_profiles, :transfer_enabled, :boolean, default: false
    end
    
    unless column_exists?(:saturn_agent_profiles, :transfer_agent_id)
      add_column :saturn_agent_profiles, :transfer_agent_id, :bigint
      add_index :saturn_agent_profiles, :transfer_agent_id
    end
  end
end
