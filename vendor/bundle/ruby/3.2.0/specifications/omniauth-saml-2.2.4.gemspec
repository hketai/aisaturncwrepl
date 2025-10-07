# -*- encoding: utf-8 -*-
# stub: omniauth-saml 2.2.4 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-saml".freeze
  s.version = "2.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Raecoo Cao".freeze, "Ryan Wilcox".freeze, "Rajiv Aaron Manglani".freeze, "Steven Anderson".freeze, "Nikos Dimitrakopoulos".freeze, "Rudolf Vriend".freeze, "Bruno Pedro".freeze]
  s.date = "2025-05-27"
  s.description = "A generic SAML strategy for OmniAuth.".freeze
  s.homepage = "https://github.com/omniauth/omniauth-saml".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "A generic SAML strategy for OmniAuth.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<omniauth>.freeze, ["~> 2.1"])
  s.add_runtime_dependency(%q<ruby-saml>.freeze, ["~> 1.18"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.2"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.13"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.10"])
  s.add_development_dependency(%q<rack-test>.freeze, ["~> 2.1"])
  s.add_development_dependency(%q<conventional-changelog>.freeze, ["~> 1.3"])
  s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8"])
end
