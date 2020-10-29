# frozen_string_literal: true

require "json"

RSpec.describe Blockhash do
  it "has a version number" do
    expect(Blockhash::VERSION).not_to be nil
  end

  describe "distance" do
    subject(:distance) { described_class.distance(hash1, hash2) }

    let(:hash1) { "000000004c00c0808080bc409c409fc0d9c0d9c0fbc0bfc0001f001f1c3f1fff" }
    let(:hash2) { "073f073f0f3f8501e000f801d0ffde00de00c600fe00ee00c0ff00ff0dff0000" }

    it "calculates the hamming distance between two hex hashes" do
      expect(distance).to eq(99)
    end

    describe "when the hashes are identical" do
      let(:hash2) { "000000004c00c0808080bc409c409fc0d9c0d9c0fbc0bfc0001f001f1c3f1fff" }

      it "returns 0" do
        expect(distance).to eq(0)
      end
    end
  end

  describe "similar?" do
    let(:hash1) { "000000004c00c0808080bc409c409fc0d9c0d9c0fbc0bfc0001f001f1c3f1fff" }
    let(:hash2) { "000000004c00c0808080bc409c409fc0d9c0d9c0fbc0bfc0001f001f1ceeeeee" }

    context "when no threshold is provided" do
      let(:similar?) { described_class.similar?(hash1, hash2) }

      it "returns false" do
        expect(similar?).to be false
      end
    end

    describe "when a threshold is provided" do
      let(:similar?) { described_class.similar?(hash1, hash2, 12) }

      it "returns true" do
        expect(similar?).to be true
      end
    end
  end

  file = File.read("spec/fixtures/hashes.json")
  expected_values = JSON.parse(file)

  describe "calculate_fast" do
    subject(:calculate_fast) { described_class.calculate_fast(img) }

    expected_values.each do |val|
      context "when test image #{val['file']}" do
        let(:img) { Magick::Image.read("spec/fixtures/#{val['file']}").first }

        it "returns correct hash" do
          expect(calculate_fast).to eq(val["fast"])
        end
      end
    end
    context "when using an odd number of bits" do
      subject(:calculate_fast) { described_class.calculate_fast(img, 15) }

      expected_values.each do |val|
        context "when test image #{val['file']}" do
          let(:img) { Magick::Image.read("spec/fixtures/#{val['file']}").first }

          it "returns correct hash" do
            expect(calculate_fast).to eq(val["oddbits"])
          end
        end
      end
    end
  end

  describe "calculate" do
    subject(:calculate) { described_class.calculate(img) }

    expected_values.each do |val|
      context "when test image #{val['file']}" do
        let(:img) { Magick::Image.read("spec/fixtures/#{val['file']}").first }

        it "returns correct hash" do
          expect(calculate).to eq(val["exact"])
        end
      end
    end
  end
end
