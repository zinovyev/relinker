require "digest"
require "pry"

module Relinker
  class Discoverer
    def collect(base_dir)
      cache_file = "#{Dir.pwd}/relinker_cache_#{Time.now.to_i}"
      File.open(cache_file, "a+") do |cache|
        discover(base_dir) do |file, checksum|
          cache.writeln("#{checksum} #{file}\n")
        end
      end
    end

    def discover(base_dir)
      children = Pathname.new(base_dir).children
      children.each do |child|
        next if child.symlink?
        if child.directory?
          discover(child) { |file| yield(file, checksum(file)) }
        else
          yield(child, checksum(child))
        end
      end
    end

    def list(base_dir)
      files = []
      discover(base_dir) do |file, check|
        files << { path: file.to_s, checksum: check }
      end
      files
    end

    private

    def checksum(file)
      Digest::MD5.file(file).hexdigest
    end
  end
end
