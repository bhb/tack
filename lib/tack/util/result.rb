module Tack

  module Util

    class Result

      attr_accessor :test, :failure, :status

      def self.for_test(test, failure = nil)
        self.new(:test => test, :failure => failure)
      end

      def initialize(opts)
        @test = opts.fetch(:test)
        @failure = opts.fetch(:failure) { nil }
        @status = opts.fetch(:status) { :passed }
      end

      def to_basics
        { :status => status,
          :test => basics(test),
          :failure => basics(failure)
        }
      end

    end

  end
end
