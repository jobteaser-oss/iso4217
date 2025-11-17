# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iso4217/version"

Gem::Specification.new do |s|
  s.name = "iso4217-rb"
  s.version = "1.2.#{ISO4217::VERSION.delete("-")}"
  s.platform = Gem::Platform::RUBY
  s.license = "MIT"
  s.summary = "ISO 4217 Currency Codes"
  s.description = "A Ruby library that provides ISO 4217 currency codes and related information."
  s.homepage = "https://github.com/jobteaser-oss/iso4217"
  s.authors = ["Jobteaser SAI — Chapter Backend Team"]
  s.email = ["chapter-backend@jobteaser.com"]

  s.required_ruby_version = ">= 3.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "rexml"

  s.files = Dir["lib/**/*.rb", "config/**/*.json"]
  s.require_paths = ["lib"]
end
