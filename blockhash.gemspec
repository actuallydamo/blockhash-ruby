# frozen_string_literal: true

require_relative "lib/blockhash/version"

Gem::Specification.new do |spec|
  spec.name          = "blockhash"
  spec.version       = Blockhash::VERSION
  spec.license       = "MIT"
  spec.authors       = ["Damien Kingsley"]
  spec.email         = ["actuallydamo@gmail.com"]
  spec.summary       = "Generate and compare perceptual image hashes using the blockhash method"
  spec.description   = "This is a perceptual image hash calculation and comparison tool based on the blockhash method."
  spec.description  += " This can be used to match compressed or resized images to each other."
  spec.homepage      = "https://github.com/actuallydamo/blockhash-ruby"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")
  spec.requirements << "ImageMagick"
  spec.add_dependency("rmagick", "~> 4.2.5")
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.files         = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
