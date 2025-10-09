json.payload do
  json.array! @knowledge_sources do |source|
    json.id source.id
    json.title source.title
    json.source_url source.source_url
    json.source_type source.source_type
    json.agent_profile_id source.agent_profile_id
    json.content_preview source.content_text&.truncate(200)
    json.created_at source.created_at
    json.metadata source.metadata
  end
end
