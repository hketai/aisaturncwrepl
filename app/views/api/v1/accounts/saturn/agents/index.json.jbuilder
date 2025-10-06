json.payload do
  json.array! @agents do |agent|
    json.id agent.id
    json.name agent.name
    json.description agent.description
    json.active agent.active
    json.ai_temperature agent.ai_temperature
    json.product_context agent.product_context
    json.industry_type agent.industry_type
    json.avatar_url agent.avatar_url.presence || agent.send(:default_avatar_url)
    json.created_at agent.created_at
    json.updated_at agent.updated_at
  end
end
