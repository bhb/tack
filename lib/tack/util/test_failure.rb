module Tack

  module Util

    class TestFailure
      
      attr_accessor :message, :backtrace

      def initialize(message='', backtrace=[])
        @message = message
        @backtrace = backtrace
      end

      def to_basics
        { :message => message,
          :backtrace => backtrace }
      end
      
    end

  end

end
