module Tack

  module Formatter

    class BasicSummary

      def process(result)
      end

      def finish(results)
        # 11 tests, 26 assertions, 0 failures, 0 errors
        puts "%d tests, %d failures, %d pending" % [results.length, results[:failed].length, results[:pending].length]
      end
      
    end

  end

end
