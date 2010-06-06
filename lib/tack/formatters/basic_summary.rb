module Tack

  module Formatters

    class BasicSummary

      def process(result)
      end

      def finish(results)
        puts "%d tests, %d failures, %d pending" % [results.values.flatten.length, results[:failed].length, results[:pending].length]
      end
      
    end

  end

end
