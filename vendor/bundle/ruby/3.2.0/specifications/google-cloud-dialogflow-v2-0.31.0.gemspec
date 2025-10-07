# -*- encoding: utf-8 -*-
# stub: google-cloud-dialogflow-v2 0.31.0 ruby lib

Gem::Specification.new do |s|
  s.name = "google-cloud-dialogflow-v2".freeze
  s.version = "0.31.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Google LLC".freeze]
  s.date = "2024-01-03"
  s.description = "Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices. You can use it to build interfaces (such as chatbots and conversational IVR) that enable natural and rich interactions between your users and your business. This client is for Dialogflow ES, providing the standard agent type suitable for small and simple agents. Note that google-cloud-dialogflow-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-dialogflow instead. See the readme for more details.".freeze
  s.email = "googleapis-packages@google.com".freeze
  s.homepage = "https://github.com/googleapis/google-cloud-ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Builds conversational interfaces (for example, chatbots, and voice-powered apps and devices).".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<gapic-common>.freeze, [">= 0.20.0", "< 2.a"])
  s.add_runtime_dependency(%q<google-cloud-errors>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<google-cloud-location>.freeze, [">= 0.4", "< 2.a"])
  s.add_development_dependency(%q<google-style>.freeze, ["~> 1.26.3"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.16"])
  s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
  s.add_development_dependency(%q<minitest-rg>.freeze, ["~> 5.2"])
  s.add_development_dependency(%q<rake>.freeze, [">= 13.0"])
  s.add_development_dependency(%q<redcarpet>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.18"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9"])
end
