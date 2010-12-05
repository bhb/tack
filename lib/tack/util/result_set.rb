module Tack

  module Util
    
    class ResultSet

      attr_accessor :passed, :failed, :pending

      def initialize(results={})
        @results = basics(results)
      end

      def passed
        @passed ||= result_objects(@results[:passed])
      end

      def pending
        @pending ||= result_objects(@results[:pending])
      end

      def failed
        @failed ||= result_objects(@results[:failed])
      end

      def length
        passed.length + failed.length + pending.length
      end

      def to_basics
        { :passed => passed.map {|x| basics(x)},
          :failed => failed.map{|x| basics(x)},
          :pending => pending.map{|x| basics(x)} }
      end

      def pass(test)
        passed << Result.for_test(test)
      end

      def fail(test, failure)
        failed << Result.for_test(test, failure)
      end

      def pend(test)
        pending << Result.for_test(test)
      end

      def <<(result)
        case result[:status]
        when :passed
          self.passed << result
        when :failed
          self.failed << result
        when :pending
          self.pending << result
        else
          raise "Unknown result status: #{result[:status]}"
        end
      end

      private
      
      def result_objects(results)
        if results == nil
          []
        else
          results.map do |result| 
            Result.new(result)
          end
        end
      end

    end

  end

end
