require "relinker"
require "timecop"

RSpec.describe Relinker::Discoverer do
  let(:test_dir) { "#{__dir__}/test_dir" }
  let(:temp_dir) { "#{__dir__}/tmp" }

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
  end

  describe "#collect" do
    Timecop.freeze(Time.local(2015, 3, 20)) do
      subject { described_class.new(cache_dir: temp_dir) }
      let(:cache_file) { "#{temp_dir}/relinker_cache_#{Time.now.to_i}" }
      it "should create file with checksums" do
        subject.collect(test_dir)
        expect(File.exist?(cache_file)).to eq(true)
      end

      it "should write proper checksums to file" do
        subject.collect(test_dir)
        files = subject.list(test_dir)
        asdf = files.find { |file| file[:path].match(/asdf/) }
        test1 = files.find { |file| file[:path].match(/test1/) }
        test2 = files.find { |file| file[:path].match(/test2/) }
        test3 = files.find { |file| file[:path].match(/test3/) }
        file_lines = File.readlines(cache_file)
        expect(file_lines).to include("#{asdf[:checksum]}$$$\t#{asdf[:path]}\n")
        expect(file_lines).to include("#{test1[:checksum]}$$$\t#{test1[:path]}\n")
        expect(file_lines).to include("#{test2[:checksum]}$$$\t#{test2[:path]}\n")
        expect(file_lines).to include("#{test3[:checksum]}$$$\t#{test3[:path]}\n")
      end
    end
  end
end
