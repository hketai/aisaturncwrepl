class CreateSaturnTables < ActiveRecord::Migration[7.1]
  def up
    ensure_vector_extension
    create_saturn_agent_profiles
    create_saturn_knowledge_sources
    create_saturn_auto_replies
    create_saturn_inbox_connections
  end

  def down
    drop_table :saturn_inbox_connections if table_exists?(:saturn_inbox_connections)
    drop_table :saturn_auto_replies if table_exists?(:saturn_auto_replies)
    drop_table :saturn_knowledge_sources if table_exists?(:saturn_knowledge_sources)
    drop_table :saturn_agent_profiles if table_exists?(:saturn_agent_profiles)
  end

  private

  def ensure_vector_extension
    return if extension_enabled?('vector')

    begin
      enable_extension 'vector'
    rescue ActiveRecord::StatementInvalid
      Rails.logger.warn "Vector extension already enabled or not available"
    end
  end

  def create_saturn_agent_profiles
    create_table :saturn_agent_profiles do |t|
      t.string :name, null: false
      t.text :description
      t.bigint :account_id, null: false
      t.jsonb :configuration, default: {}, null: false
      t.jsonb :behavior_rules, default: []
      t.jsonb :safety_guidelines, default: []
      t.float :ai_temperature, default: 0.7
      t.boolean :active, default: true
      t.string :product_context

      t.timestamps
    end

    add_index :saturn_agent_profiles, :account_id
    add_index :saturn_agent_profiles, [:account_id, :name], unique: true
    add_index :saturn_agent_profiles, :active
  end

  def create_saturn_knowledge_sources
    create_table :saturn_knowledge_sources do |t|
      t.string :title, null: false
      t.string :source_url
      t.text :content_text
      t.string :source_type, default: 'document'
      t.bigint :agent_profile_id, null: false
      t.bigint :account_id, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :saturn_knowledge_sources, :account_id
    add_index :saturn_knowledge_sources, :agent_profile_id
    add_index :saturn_knowledge_sources, :source_type
  end

  def create_saturn_auto_replies
    create_table :saturn_auto_replies do |t|
      t.text :user_query, null: false
      t.text :agent_response, null: false
      t.vector :query_embedding, limit: 1536
      t.bigint :agent_profile_id, null: false
      t.bigint :knowledge_source_id
      t.bigint :account_id, null: false
      t.float :confidence_score
      t.jsonb :context_data, default: {}

      t.timestamps
    end

    add_index :saturn_auto_replies, :account_id
    add_index :saturn_auto_replies, :agent_profile_id
    add_index :saturn_auto_replies, :knowledge_source_id
    add_index :saturn_auto_replies, :query_embedding, 
              using: :ivfflat, 
              name: 'idx_saturn_replies_embedding', 
              opclass: :vector_l2_ops
  end

  def create_saturn_inbox_connections
    create_table :saturn_inbox_connections do |t|
      t.bigint :agent_profile_id, null: false
      t.bigint :inbox_id, null: false
      t.boolean :auto_respond, default: false
      t.jsonb :connection_settings, default: {}

      t.timestamps
    end

    add_index :saturn_inbox_connections, :agent_profile_id
    add_index :saturn_inbox_connections, :inbox_id
    add_index :saturn_inbox_connections, [:agent_profile_id, :inbox_id], 
              unique: true, 
              name: 'idx_saturn_unique_inbox_connection'
  end
end
