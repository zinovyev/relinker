require "relinker"
require "timecop"

RSpec.describe Relinker::Discoverer do
  Timecop.freeze(Time.local(2015, 3, 20)) do
    let(:test_dir) { "#{__dir__}/test_dir" }
    let(:temp_dir) { "#{__dir__}/tmp" }
    let(:cache_file) { "#{temp_dir}/relinker_cache_#{Time.now.to_i}" }
    subject { described_class.new(cache_file) }

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
        [asdf, test1, test2, test3].each do |definition|
          expect(file_lines)
            .to include("#{definition[:checksum]}$$$\t#{definition[:path]}\n")
        end
      end
    end
  end
end
