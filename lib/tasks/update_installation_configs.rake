namespace :installation do
  desc 'Update installation configs from YAML without triggering onboarding'
  task update_configs: :environment do
    puts '🔧 Updating installation configs from config/installation_config.yml...'
    
    GlobalConfig.clear_cache
    ConfigLoader.new.process
    
    puts '✅ Installation configs updated successfully!'
    puts ''
    puts 'Updated configs:'
    ['INSTALLATION_NAME', 'LOGO', 'LOGO_DARK', 'LOGO_THUMBNAIL', 'BRAND_NAME', 'BRAND_URL'].each do |config_name|
      config = InstallationConfig.find_by(name: config_name)
      puts "  - #{config_name}: #{config&.value || 'NOT SET'}"
    end
  end
end
