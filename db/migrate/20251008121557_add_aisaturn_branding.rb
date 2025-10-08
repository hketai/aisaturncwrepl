class AddAisaturnBranding < ActiveRecord::Migration[7.1]
  def up
    # Set AISATURN logo for light mode
    InstallationConfig.find_or_create_by(name: 'LOGO') do |config|
      config.value = '/brand-assets/new_logo.png'
      config.locked = false
    end

    # Set AISATURN logo for dark mode
    InstallationConfig.find_or_create_by(name: 'LOGO_DARK') do |config|
      config.value = '/brand-assets/new_logo_dark.png'
      config.locked = false
    end

    # Set brand name
    InstallationConfig.find_or_create_by(name: 'BRAND_NAME') do |config|
      config.value = 'AISATURN'
      config.locked = false
    end

    # Clear cache to apply changes immediately
    GlobalConfig.clear_cache if defined?(GlobalConfig)
  end

  def down
    InstallationConfig.find_by(name: 'LOGO')&.destroy
    InstallationConfig.find_by(name: 'LOGO_DARK')&.destroy
    InstallationConfig.find_by(name: 'BRAND_NAME')&.destroy
    GlobalConfig.clear_cache if defined?(GlobalConfig)
  end
end
