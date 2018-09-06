module Relinker
  class Linker

    attr_reader :options, :cache_file

    def initialize(cache_file, options = {})
      @cache_file = cache_file
      @options = options
      reset_state
    end

    def loop_identicals(&block)
      loop_files do |checksum, file|
        publish_state(&block) if checksum != @prev_checksum
        update_state(checksum, file)
      end
      publish_state(&block)
    end

    def loop_files
      File.open(@cache_file, "r") do |cache|
        cache.each do |line|
          yield line.split("$$$\t").map(&:strip)
        end
      end
    end

    private

    def publish_state
      yield(@prev_checksum, @identicals) unless @identicals.empty?
      reset_state
    end

    def update_state(checksum, file)
      @prev_checksum = checksum
      @identicals << file
    end

    def reset_state
      @prev_checksum = nil
      @identicals = []
    end
  end
end
