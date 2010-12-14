module Tack

  class ConfigFile

    def self.read(stdout)
      path = '.tackrc'
      if File.exists?(path)
        stdout.puts "Found .tackrc"
        eval File.read(path)
      else
        Tack::config {}
        stdout.puts "No .tackrc found. Only using command line arguments"
      end
    end

  end

  
  attr_reader :options
  def config
    @options = {}
    yield @options if block_given?
  end

  extend(self)
end
