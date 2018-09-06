require "relinker"

RSpec.describe Relinker::Linker do
  let(:cache_file) { "#{__dir__}/tmp/relinker_cache_123" }
  subject { described_class.new(cache_file) }

  before do
    File.open(cache_file, "a+") do |file|
      content = <<-TXT.gsub(/^\s+/, "")
        37b51d194a7513e45b56f6524f2d51f2$$$	#{__dir__}/test_dir/a/test1.txt
        ae3e83e2fab3a7d8683d8eefabd1e74d$$$	#{__dir__}/test_dir/b/test2.pdf
        acbd18db4cc2f85cedef654fccc4a4d8$$$	#{__dir__}/test_dir/c/d/test3.log
        acbd18db4cc2f85cedef654fccc4a4d8$$$	#{__dir__}/test_dir/asdf
      TXT
      file.write(content)
    end
  end


  describe "#identical_files" do
    it "should list files from cache file" do
      identicals1 = [
        "37b51d194a7513e45b56f6524f2d51f2",
        ["#{__dir__}/test_dir/a/test1.txt"]
      ]

      identicals2 = [
        "ae3e83e2fab3a7d8683d8eefabd1e74d",
        ["#{__dir__}/test_dir/b/test2.pdf"]
      ]

      identicals3 = [
        "acbd18db4cc2f85cedef654fccc4a4d8",
        ["#{__dir__}/test_dir/c/d/test3.log", "#{__dir__}/test_dir/asdf"]
      ]

      expect { |b| subject.loop_identicals(&b) }.to yield_successive_args(identicals1,
                                                                          identicals2,
                                                                          identicals3)
    end
  end
end
