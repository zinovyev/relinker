require "bundler/setup"
require "relinker"
require "fileutils"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    FileUtils.rm_rf(test_dir)
    FileUtils.mkdir_p("#{__dir__}/tmp")
    FileUtils.mkdir_p("#{test_dir}/a")
    FileUtils.mkdir_p("#{test_dir}/b")
    FileUtils.mkdir_p("#{test_dir}/c/d")
    File.open("#{test_dir}/asdf", "a+") { |file| file.write("foo") }
    File.open("#{test_dir}/a/test1.txt", "a+") { |file| file.write("bar") }
    File.open("#{test_dir}/b/test2.pdf", "a+") { |file| file.write("boo") }
    File.open("#{test_dir}/c/d/test3.log", "a+") { |file| file.write("foo") }
    FileUtils.symlink("#{test_dir}/c/d/test3.log", "#{test_dir}/c/d/test4.log")
  end

  config.after do
    FileUtils.rm_rf(test_dir)
    FileUtils.rm_rf("#{__dir__}/tmp")
  end

  def test_dir
    @_test_dir ||= "#{__dir__}/test_dir"
  end
end
