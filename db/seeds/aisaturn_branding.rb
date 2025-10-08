# AISATURN Branding Configuration
# This seed file sets up the AISATURN branding in the database

puts "Setting up AISATURN branding..."

# Logo configurations
InstallationConfig.find_or_initialize_by(name: 'LOGO').tap do |config|
  config.value = '/brand-assets/new_logo.png'
  config.locked = false
  config.save!
end

InstallationConfig.find_or_initialize_by(name: 'LOGO_DARK').tap do |config|
  config.value = '/brand-assets/new_logo_dark.png'
  config.locked = false
  config.save!
end

InstallationConfig.find_or_initialize_by(name: 'LOGO_THUMBNAIL').tap do |config|
  config.value = '/brand-assets/new_logo.png'
  config.locked = false
  config.save!
end

# Brand name
InstallationConfig.find_or_initialize_by(name: 'BRAND_NAME').tap do |config|
  config.value = 'AISATURN'
  config.locked = false
  config.save!
end

# Clear cache
GlobalConfig.clear_cache if defined?(GlobalConfig)

puts "✅ AISATURN branding configured successfully!"
