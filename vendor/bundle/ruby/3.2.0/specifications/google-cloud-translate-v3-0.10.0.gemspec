# -*- encoding: utf-8 -*-
# stub: google-cloud-translate-v3 0.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "google-cloud-translate-v3".freeze
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Google LLC".freeze]
  s.date = "2024-01-03"
  s.description = "Cloud Translation can dynamically translate text between thousands of language pairs. Translation lets websites and programs programmatically integrate with the translation service. Note that google-cloud-translate-v3 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-translate instead. See the readme for more details.".freeze
  s.email = "googleapis-packages@google.com".freeze
  s.homepage = "https://github.com/googleapis/google-cloud-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Integrates text translation into your website or application.".freeze

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
