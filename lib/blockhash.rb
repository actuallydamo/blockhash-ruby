# frozen_string_literal: true

require "blockhash/version"
require "rmagick"

module Blockhash
  DEFAULT_BITS = 16

  def self.distance(hash1, hash2)
    (hash1.to_i(16) ^ hash2.to_i(16)).to_s(2).count("1")
  end

  def self.similar?(hash1, hash2, thresh = 10)
    distance(hash1, hash2) < thresh
  end

  def self.calculate_fast(img, bits = DEFAULT_BITS)
    hashsize = bits**2
    big_x = img.columns > hashsize
    big_y = img.rows > hashsize
    if big_x || big_y
      cols = big_x ? hashsize : (img.columns / bits) * bits
      rows = big_y ? hashsize : (img.rows / bits) * bits
      img.resize!(cols, rows, Magick::TriangleFilter)
    end
    calculate_even(img, bits)
  end

  def self.calculate_even(img, bits = DEFAULT_BITS)
    if img.alpha?
      total_value = method(:total_value_rgba)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGBA")
    else
      total_value = method(:total_value_rgb)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGB")
    end
    blocksize_y = img.rows / bits
    blocksize_x = img.columns / bits
    result = (0...bits).flat_map do |y|
      (0...bits).map do |x|
        (0...blocksize_y).reduce(0) do |sum_y, iy|
          cy = y * blocksize_y + iy
          sum_y + (0...blocksize_x).reduce(0) do |sum_x, ix|
            cx = x * blocksize_x + ix
            sum_x + total_value.call(img_data, img.columns, cx, cy)
          end
        end
      end
    end
    # puts result.join(", ")
    bits_to_hexhash(blocks_to_bits(result, blocksize_y * blocksize_x))
  end

  def self.calculate(img, bits = DEFAULT_BITS)
    even_x = (img.columns % bits).zero?
    even_y = (img.rows % bits).zero?
    return calculate_even(img, bits) if even_x && even_y

    raise "Not implemented"
    if img.alpha?
      total_value = method(:total_value_rgba)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGBA")
    else
      total_value = method(:total_value_rgb)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGB")
    end

  end

  private_class_method def self.chunk(string, size)
    string.unpack("a#{size}" * (string.size / size))
  end

  private_class_method def self.median(array)
    sorted = array.sort
    length = array.length
    middle = length / 2
    return sorted[middle] if length.odd?

    (sorted[middle - 1] + sorted[middle]) / 2.0
  end

  private_class_method def self.total_value_rgba(img, cols, px_x, px_y)
    i = (px_y * cols * 4 + px_x * 4)
    # Set to max value if pixel is transparent
    return Magick::QuantumRange * 3 if img[i + 3].zero?

    img[i] + img[i + 1] + img[i + 2]
  end

  private_class_method def self.total_value_rgb(img, cols, px_x, px_y)
    i = (px_y * cols * 3 + px_x * 3)
    img[i] + img[i + 1] + img[i + 2]
  end

  private_class_method def self.bits_to_hexhash(bits)
    chunk(bits, 4).reduce("") do |acc, chunk|
      acc + chunk.to_i(2).to_s(16)
    end
  end

  private_class_method def self.blocks_to_bits(blocks, pixels_per_block)
    half_block = pixels_per_block * Magick::QuantumRange * 3 / 2.0
    # puts pixels_per_block
    # puts "HALF BLOCK --- #{half_block}"
    bandsize = blocks.length / 4
    blocks.each_slice(bandsize).reduce("") do |band_acc, band|
      med = median(band)
      band_acc + band.reduce("") do |block_acc, block|
        # puts "#{block} > #{med} || ((#{block} - #{med}).abs < 1 && #{med} > #{half_block})"
        # puts block > med || ((block - med).abs < 1 && med > half_block)
        result = block > med || ((block - med).abs < 1 && med > half_block)
        block_acc + (result ? "1" : "0")
      end
    end
  end
end
