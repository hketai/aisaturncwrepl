class AddIndustryTypeToSaturnAgentProfiles < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:saturn_agent_profiles, :industry_type)
      add_column :saturn_agent_profiles, :industry_type, :string
    end
  end
end
