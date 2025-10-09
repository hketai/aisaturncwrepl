class AddIntentRoutingToSaturnAgentProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :saturn_agent_profiles, :intent_routing_enabled, :boolean
    add_column :saturn_agent_profiles, :intent_team_mappings, :jsonb
    add_column :saturn_agent_profiles, :intent_agent_mappings, :jsonb
  end
end
