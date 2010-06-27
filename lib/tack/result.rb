module Tack

  class Result

    attr_accessor :test, :failure

    def initialize(opts)
      @test = opts.fetch(:test)
      @failure = opts.fetch(:failure) { nil }
    end

    def ==(other)
      other.is_a?(Result) && @test == other.test && @failure == other.failure
    end

  end

end
