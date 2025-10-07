# -*- encoding: utf-8 -*-
# stub: google-cloud-location 0.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "google-cloud-location".freeze
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Google LLC".freeze]
  s.date = "2023-09-12"
  s.description = "An add-on interface used by some Google API clients to provide location management calls.".freeze
  s.email = "googleapis-packages@google.com".freeze
  s.homepage = "https://github.com/googleapis/google-cloud-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "API Client library for the Locations API".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<gapic-common>.freeze, [">= 0.20.0", "< 2.a"])
  s.add_runtime_dependency(%q<google-cloud-errors>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<google-style>.freeze, ["~> 1.26.3"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.16"])
  s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
  s.add_development_dependency(%q<minitest-rg>.freeze, ["~> 5.2"])
  s.add_development_dependency(%q<rake>.freeze, [">= 13.0"])
  s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
end
