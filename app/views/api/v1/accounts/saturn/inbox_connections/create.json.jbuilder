json.id @inbox_connection.id
json.agent_profile_id @inbox_connection.agent_profile_id
json.inbox_id @inbox_connection.inbox_id
json.auto_respond @inbox_connection.auto_respond
json.connection_settings @inbox_connection.connection_settings
json.inbox do
  json.id @inbox_connection.inbox.id
  json.name @inbox_connection.inbox.name
  json.channel_type @inbox_connection.inbox.channel_type
end
json.created_at @inbox_connection.created_at
