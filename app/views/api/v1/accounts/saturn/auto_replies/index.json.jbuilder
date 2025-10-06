json.payload do
  json.array! @auto_replies do |reply|
    json.id reply.id
    json.user_query reply.user_query
    json.agent_response reply.agent_response
    json.confidence_score reply.confidence_score
    json.agent_profile_id reply.agent_profile_id
    json.knowledge_source_id reply.knowledge_source_id
    json.created_at reply.created_at
  end
end
