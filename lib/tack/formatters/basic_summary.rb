module Tack

  module Formatters

    class BasicSummary
      include Middleware::Base

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          pending = results[:pending]
          failed = results[:failed]
          @output.puts "%d tests, %d failures, %d pending" % [results.length, failed.length, pending.length]
        end
      end
      
    end

  end

end
