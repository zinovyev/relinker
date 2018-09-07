require "digest"

module Relinker
  class Discoverer

    attr_reader :options, :cache_file

    def initialize(cache_file, options = {})
      @cache_file = cache_file
      @options = options
    end

    def collect(base_dir)
      File.open(cache_file, "a+") do |cache|
        discover(base_dir) do |file, checksum|
          cache.write("#{checksum}$$$\t#{file}\n")
        end
      end
      resort_cache
    end

    def resort_cache
      system("cat #{cache_file} | sort | uniq | cat > #{cache_file}.tmp \
              && mv #{cache_file}.tmp #{cache_file}")
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

    def merge_options(options = {})
      options = options.map { |key, val| [key.to_sym, val] }.to_h
      default_options.merge(options)
    end

    def default_options
      { cache_dir: "/tmp" }
    end

    def checksum(file)
      Digest::MD5.file(file).hexdigest
    end
  end
end
