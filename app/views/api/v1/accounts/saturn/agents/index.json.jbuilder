json.payload do
  json.array! @agents do |agent|
    json.id agent.id
    json.name agent.name
    json.description agent.description
    json.enabled agent.enabled
    json.ai_temperature agent.ai_temperature
    json.product_context agent.product_context
    json.industry_type agent.industry_type
    json.handoff_enabled agent.handoff_enabled
    json.handoff_team_id agent.handoff_team_id
    json.transfer_enabled agent.transfer_enabled
    json.transfer_agent_id agent.transfer_agent_id
    json.intent_routing_enabled agent.intent_routing_enabled
    json.intent_team_mappings agent.intent_team_mappings
    json.intent_agent_mappings agent.intent_agent_mappings
    json.avatar_url agent.avatar_url.presence || agent.send(:default_avatar_url)
    json.created_at agent.created_at
    json.updated_at agent.updated_at
  end
end
