# frozen_string_literal: true

require "blockhash/version"
require "rmagick"
# Blockhash module
module Blockhash
  DEFAULT_BITS = 16

  def self.distance(hash1, hash2)
    (hash1.to_i(16) ^ hash2.to_i(16)).to_s(2).count("1")
  end

  def self.similar?(hash1, hash2, thresh = 10)
    distance(hash1, hash2) < thresh
  end

  def self.calculate_fast(img, bits = DEFAULT_BITS)
    if img.alpha?
      total_value = method(:total_value_rgba)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGBA")
    else
      total_value = method(:total_value_rgb)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGB")
    end
    blocksize_y = img.rows / bits
    blocksize_x = img.columns / bits
    # Loop through each block
    result = (0...bits).flat_map do |y|
      (0...bits).map do |x|
        # Sum all pixels in block
        (0...blocksize_y).sum do |iy|
          cy = (y * blocksize_y) + iy
          (0...blocksize_x).sum do |ix|
            cx = (x * blocksize_x) + ix
            total_value.call(img_data, img.columns, cx, cy)
          end
        end
      end
    end
    bits_to_hexhash(blocks_to_bits(result, blocksize_y * blocksize_x))
  end

  def self.calculate(img, bits = DEFAULT_BITS)
    even_x = (img.columns % bits).zero?
    even_y = (img.rows % bits).zero?
    return calculate_fast(img, bits) if even_x && even_y

    if img.alpha?
      total_value = method(:total_value_rgba)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGBA")
    else
      total_value = method(:total_value_rgb)
      img_data = img.export_pixels(0, 0, img.columns, img.rows, "RGB")
    end

    blocks = Array.new(bits**2, 0)
    block_width = img.columns / bits.to_f
    block_height = img.rows / bits.to_f

    (0...img.rows).each do |y|
      b_top, b_bottom, w_top, w_bottom = block_overlaps(y, img.rows, block_height, even_y)
      top_index = b_top * bits
      bottom_index = b_bottom * bits
      (0...img.columns).each do |x|
        value = total_value.call(img_data, img.columns, x, y)
        b_left, b_right, w_left, w_right = block_overlaps(x, img.columns, block_width, even_x)
        blocks[top_index + b_left] += value * w_top * w_left
        blocks[top_index + b_right] += value * w_top * w_right
        blocks[bottom_index + b_left] += value * w_bottom * w_left
        blocks[bottom_index + b_right] += value * w_bottom * w_right
      end
    end
    bits_to_hexhash(blocks_to_bits(blocks, block_width * block_height))
  end

  def self.calculate_from_path(path, bits = DEFAULT_BITS)
    calculate(Magick::Image.read(path).first, bits)
  end

  def self.block_overlaps(index, size, block_size, even)
    block = index / block_size
    block_prev = block.to_i
    if even
      weight_prev = 1
      weight_next = 0
      block_next = block_prev
    else
      index_int, index_frac = ((index + 1) % block_size).divmod 1
      weight_prev = 1 - index_frac
      weight_next = index_frac
      block_next = index_int.positive? || (index + 1) == size ? block_prev : block.ceil.to_i
    end
    [block_prev, block_next, weight_prev, weight_next]
  end
  private_class_method :block_overlaps

  def self.chunk(string, size)
    string.unpack("a#{size}" * (string.size / size))
  end
  private_class_method :chunk

  def self.median(array)
    sorted = array.sort
    length = array.length
    middle = length / 2
    return sorted[middle] if length.odd?

    (sorted[middle - 1] + sorted[middle]) / 2.0
  end
  private_class_method :median

  def self.total_value_rgba(img, cols, px_x, px_y)
    i = ((px_y * cols * 4) + (px_x * 4))
    # Set to max value if pixel is transparent
    return Magick::QuantumRange * 3 if img[i + 3].zero?

    # Sum RGB values
    img[i] + img[i + 1] + img[i + 2]
  end
  private_class_method :total_value_rgba

  def self.total_value_rgb(img, cols, px_x, px_y)
    i = ((px_y * cols * 3) + (px_x * 3))
    # Sum RGB values
    img[i] + img[i + 1] + img[i + 2]
  end
  private_class_method :total_value_rgb

  def self.bits_to_hexhash(bits)
    chunk(bits, 4).sum("") do |chunk|
      chunk.to_i(2).to_s(16)
    end
  end
  private_class_method :bits_to_hexhash

  def self.blocks_to_bits(blocks, pixels_per_block)
    # Half of the max total colour value for the block
    half_block = pixels_per_block * Magick::QuantumRange * 3 / 2.0
    # Split image into 4 horizontal bands
    bandsize = blocks.length / 4
    # Loop over each band
    blocks.each_slice(bandsize).sum("") do |band|
      med = median(band)
      band.sum("") do |block|
        block > med || ((block - med).abs < 1 && med > half_block) ? "1" : "0"
      end
    end
  end
  private_class_method :blocks_to_bits
end
