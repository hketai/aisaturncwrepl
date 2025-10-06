json.payload do
  json.array! @inbox_connections do |connection|
    json.id connection.id
    json.agent_profile_id connection.agent_profile_id
    json.inbox_id connection.inbox_id
    json.auto_respond connection.auto_respond
    json.connection_settings connection.connection_settings
    json.inbox do
      json.id connection.inbox.id
      json.name connection.inbox.name
      json.channel_type connection.inbox.channel_type
    end
    json.created_at connection.created_at
  end
end
