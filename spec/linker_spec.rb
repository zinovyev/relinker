require "relinker"

RSpec.describe Relinker::Linker do
  let(:cache_file) { "#{__dir__}/tmp/relinker_cache_123" }
  let(:file1) { "#{__dir__}/test_dir/a/test1.txt" }
  let(:file2) { "#{__dir__}/test_dir/b/test2.pdf" }
  let(:file3) { "#{__dir__}/test_dir/c/d/test3.log" }
  let(:file4) { "#{__dir__}/test_dir/asdf" }
  subject { described_class.new(cache_file) }

  before do
    File.open(cache_file, "a+") do |file|
      content = <<-TXT.gsub(/^\s+/, "")
        37b51d194a7513e45b56f6524f2d51f2$$$	#{file1}
        ae3e83e2fab3a7d8683d8eefabd1e74d$$$	#{file2}
        acbd18db4cc2f85cedef654fccc4a4d8$$$	#{file3}
        acbd18db4cc2f85cedef654fccc4a4d8$$$	#{file4}
      TXT
      file.write(content)
    end
  end


  describe "#identical_files" do
    it "should list files from cache file" do
      identicals1 = ["37b51d194a7513e45b56f6524f2d51f2", [file1]]
      identicals2 = ["ae3e83e2fab3a7d8683d8eefabd1e74d", [file2]]
      identicals3 = ["acbd18db4cc2f85cedef654fccc4a4d8", [file3, file4]]
      identicals = [identicals1, identicals2, identicals3]

      expect { |b| subject.loop_identicals(&b) }
        .to yield_successive_args(*identicals)
    end
  end

  describe "#relink_identicals" do
    it "should relink files which are identical to each other" do
      inode1_was, inode2_was, inode3_was, inode4_was =
        [file1, file2, file3, file4].map do |file|
          File.stat(file).ino
        end
      inode1_was = File.stat(file1).ino
      inode2_was = File.stat(file2).ino
      inode3_was = File.stat(file3).ino
      inode4_was = File.stat(file4).ino

      subject.relink_identicals

      expect(File.stat(file1).ino).to eq(inode1_was)
      expect(File.stat(file2).ino).to eq(inode2_was)
      expect(File.stat(file4).ino).to_not eq(inode4_was)
      expect(File.stat(file3).ino).to eq(inode3_was) # Same inode
      expect(File.stat(file4).ino).to eq(inode3_was) # Same inode
    end
  end
end
