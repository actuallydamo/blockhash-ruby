# Blockhash

This is Ruby Gem that can be used to produce and compare perceptual image hashes.

This Gem is a translation of the algorithm at [http://blockhash.io](http://blockhash.io)

## Installation

### Prerequisites

On Debian/Ubuntu/Mint you can run:
```sh
sudo apt get install libmagickwand-dev
```

On Arch you can run:
```sh
pacman -Syy pkg-config imagemagick
```

On macOS, you can run:
```sh
brew install pkg-config imagemagick
```

### Gem Install

Install via Bundler
```sh
bundle add blockhash
```

Or install via RubyGems:
```sh
gem install blockhash
```

## Usage

```ruby
require "blockhash"
require "rmagick"

image1 = Magick::Image.read("image1.png").first
image2 = Magick::Image.read("image2.png").first

# Generate full image hashes
hash1 = Blockhash.calculate(image1, bits = 16)
hash2 = Blockhash.calculate(image2, bits = 16)

# Generate fast image hashes
hash1 = Blockhash.calculate_fast(image1, bits = 16)
hash2 = Blockhash.calculate_fast(image2, bits = 16)

# Generate image hash from file path
hash1 = Blockhash.calculate_from_path("image1.png", bits = 16)

# Determine if hashes are similar
similar = Blockhash.similar?(hash1, hash2, threshold = 10)

# Calculate distance between two hashes
distance = Blockhash.distance(hash1, hash2)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/actuallydamo/blockhash-ruby.
