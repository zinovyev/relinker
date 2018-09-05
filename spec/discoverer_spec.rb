require "relinker"

RSpec.describe Relinker::Discoverer do
  let(:test_dir) { "#{__dir__}/test_dir" }

  describe "#discover" do
    it "should check for files only" do
      expect(subject.list(test_dir).count).to eq(4)
    end

    it "should count checksums correct" do
      files = subject.list(test_dir)
      asdf = files.find { |file| file[:path].match(/asdf/) }
      test1 = files.find { |file| file[:path].match(/test1/) }
      test2 = files.find { |file| file[:path].match(/test2/) }
      test3 = files.find { |file| file[:path].match(/test3/) }

      expect(test3[:checksum]).to eq(asdf[:checksum])
      expect(test1[:checksum]).to_not eq(test2[:checksum])
      expect(test1[:checksum]).to_not eq(test3[:checksum])
    end

    it "should collect file names to cache file" do
      subject.collect(test_dir)
    end
  end
end
