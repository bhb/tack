module Tack

  class Result

    attr_accessor :test, :failure

    def self.for_test(test, failure = nil)
      self.new(:test => test, :failure => failure)
    end

    def initialize(opts)
      if opts.is_a?(Result)
        other = opts
        @test = other.test
        @failure = other.failure
      else
        @test = opts.fetch(:test)
        @failure = opts.fetch(:failure) { nil }
      end
    end

    def ==(other)
      other.is_a?(Result) && @test == other.test && @failure == other.failure
    end

    def to_basics
      { :test => basics(test),
        :failure => basics(failure)
      }
    end

  end

end
