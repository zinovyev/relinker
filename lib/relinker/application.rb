module Relinker
  class Application
    attr_reader :options, :dir

    def initialize(dir, options = {})
      @dir = dir
      @options = merge_options(options)
    end

    def run
      discoverer.collect(@dir)
      linker.relink_identicals
    end

    private

    def discoverer
      @_discoverer ||= Discoverer.new(cache_file, @options)
    end

    def linker
      @_linker ||= Linker.new(cache_file, @options)
    end

    def cache_file
      @_cache_file ||= "#{cache_dir}/relinker_cache_#{Time.now.to_i}"
    end

    def cache_dir
      options[:cache_dir]
    end

    def merge_options(options = {})
      options = options.map { |key, val| [key.to_sym, val] }.to_h
      default_options.merge(options)
    end

    def default_options
      { cache_dir: "/tmp" }
    end
  end
end
