# -*- encoding: utf-8 -*-
# stub: devise-two-factor 6.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "devise-two-factor".freeze
  s.version = "6.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Quinn Wilton".freeze]
  s.date = "2024-11-11"
  s.description = "Devise-Two-Factor is a minimalist extension to Devise which offers support for two-factor authentication through the TOTP scheme.".freeze
  s.homepage = "https://github.com/devise-two-factor/devise-two-factor".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Barebones two-factor authentication with Devise".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<railties>.freeze, [">= 7.0", "< 8.1"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 7.0", "< 8.1"])
  s.add_runtime_dependency(%q<devise>.freeze, ["~> 4.0"])
  s.add_runtime_dependency(%q<rotp>.freeze, ["~> 6.0"])
  s.add_development_dependency(%q<activemodel>.freeze, [">= 0"])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["> 1.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["> 3"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13"])
end
