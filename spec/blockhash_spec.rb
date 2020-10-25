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

  describe "calculate_even" do
    subject(:calculate_even) { described_class.calculate_even(img) }

    file = File.read("spec/fixtures/hashes.json")
    expected_values = JSON.parse(file)
    expected_values.each do |val|
      context "when test image #{val['file']}" do
        let(:img) { Magick::Image.read("spec/fixtures/#{val['file']}").first }

        it "returns correct hash" do
          expect(calculate_even).to eq(val["even"])
        end
      end
    end
  end
end
