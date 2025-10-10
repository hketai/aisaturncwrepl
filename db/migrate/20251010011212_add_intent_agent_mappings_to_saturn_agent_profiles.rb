class AddIntentAgentMappingsToSaturnAgentProfiles < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:saturn_agent_profiles, :intent_agent_mappings)
      add_column :saturn_agent_profiles, :intent_agent_mappings, :jsonb, default: []
    end
  end
end
