module Tack

  class Result

    attr_accessor :test, :failure

    def self.for_test(test, failure = nil)
      self.new(:test => test, :failure => failure)
    end

    def initialize(opts)
      @test = opts.fetch(:test)
      @failure = opts.fetch(:failure) { nil }
    end

    def ==(other)
      other.is_a?(Result) && @test == other.test && @failure == other.failure
    end

    def to_primitives
      { :test => test,
        :failure => failure
      }
    end

  end

end
