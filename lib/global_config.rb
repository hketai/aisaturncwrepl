class GlobalConfig
  VERSION = 'V1'.freeze
  KEY_PREFIX = 'GLOBAL_CONFIG'.freeze
  DEFAULT_EXPIRY = 1.day

  class << self
    def get(*args)
      config_keys = *args
      config = {}

      # Batch fetch from Redis using mget
      cache_keys = config_keys.map { |k| "#{VERSION}:#{KEY_PREFIX}:#{k}" }
      cached_values = $alfred.with { |conn| conn.mget(cache_keys) }

      # Identify missing keys
      missing_keys = []
      config_keys.each_with_index do |config_key, index|
        if cached_values[index].present?
          config[config_key] = JSON.parse(cached_values[index])['value']
        else
          missing_keys << config_key
        end
      end

      # Batch fetch missing keys from database
      if missing_keys.any?
        db_configs = InstallationConfig.where(name: missing_keys).index_by(&:name)
        
        missing_keys.each do |config_key|
          value_from_db = db_configs[config_key]&.value
          config[config_key] = value_from_db
          
          # Cache the value
          cache_key = "#{VERSION}:#{KEY_PREFIX}:#{config_key}"
          cached_value = { value: value_from_db }.to_json
          $alfred.with { |conn| conn.set(cache_key, cached_value, { ex: DEFAULT_EXPIRY }) }
        end
      end

      typecast_config(config)
      config.with_indifferent_access
    end

    def get_value(arg)
      load_from_cache(arg)
    end

    def clear_cache
      cached_keys = $alfred.with { |conn| conn.keys("#{VERSION}:#{KEY_PREFIX}:*") }
      (cached_keys || []).each do |cached_key|
        $alfred.with { |conn| conn.expire(cached_key, 0) }
      end
    end

    private

    def typecast_config(config)
      general_configs = ConfigLoader.new.general_configs
      config.each do |config_key, config_value|
        config_type = general_configs.find { |c| c['name'] == config_key }&.dig('type')
        config[config_key] = ActiveRecord::Type::Boolean.new.cast(config_value) if config_type == 'boolean'
      end
    end

    def load_from_cache(config_key)
      cache_key = "#{VERSION}:#{KEY_PREFIX}:#{config_key}"
      cached_value = $alfred.with { |conn| conn.get(cache_key) }

      if cached_value.blank?
        value_from_db = db_fallback(config_key)
        cached_value = { value: value_from_db }.to_json
        $alfred.with { |conn| conn.set(cache_key, cached_value, { ex: DEFAULT_EXPIRY }) }
      end

      JSON.parse(cached_value)['value']
    end

    def db_fallback(config_key)
      InstallationConfig.find_by(name: config_key)&.value
    end
  end
end
