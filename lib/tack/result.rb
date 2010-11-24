# TODO - should go in Util module
module Tack

  class Result

    attr_accessor :test, :failure, :status

    def self.for_test(test, failure = nil)
      self.new(:test => test, :failure => failure)
    end

    def initialize(opts)
      if opts.is_a?(Result)
        other = opts
        @test = other.test
        @failure = other.failure
        @status = other.status
      else
        @test = opts.fetch(:test)
        @failure = opts.fetch(:failure) { nil }
        @status = opts.fetch(:status)
      end
    end

    def ==(other)
      other.is_a?(Result) && 
        status == other.status
        test == other.test && 
        failure == other.failure
    end

    def to_basics
      { :status => status,
        :test => basics(test),
        :failure => basics(failure)
      }
    end

  end

end
