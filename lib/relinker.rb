require "relinker/version"
require "relinker/discoverer"
require "relinker/linker"
require "relinker/application"

module Relinker
  extend self

  def run(args)
    Application.new(args[0]).run
  end

  def run_threaded(_args)
    raise NotImplementedError
  end
end
