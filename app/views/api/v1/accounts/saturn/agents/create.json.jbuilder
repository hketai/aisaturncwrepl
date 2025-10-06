json.id @agent.id
json.name @agent.name
json.description @agent.description
json.active @agent.active
json.ai_temperature @agent.ai_temperature
json.product_context @agent.product_context
json.behavior_rules @agent.behavior_rules
json.safety_guidelines @agent.safety_guidelines
json.configuration @agent.configuration
json.avatar_url @agent.avatar_url.presence || @agent.send(:default_avatar_url)
json.created_at @agent.created_at
