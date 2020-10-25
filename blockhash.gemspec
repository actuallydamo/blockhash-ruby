require_relative "lib/blockhash/version"

Gem::Specification.new do |spec|
  spec.name          = "blockhash"
  spec.version       = Blockhash::VERSION
  spec.license       = "MIT"
  spec.authors       = ["Damien Kingsley"]
  spec.email         = ["actuallydamo@gmail.com"]

  spec.summary       = "Generate and compare perceptual image hashes using the blockhash method"
  spec.description   = "This is a perceptual image hash calculation and comparison tool based on the blockhash method. This can be used to match compressed or resized images to each other."
  spec.homepage      = "https://github.com/actuallydamo/blockhash-ruby"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")
  spec.add_dependency("rmagick")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
