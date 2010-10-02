module Tack
  
  module Formatters

    class PrintPending
      include Middleware::Base

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          results[:pending].each do |result|
            file, contexts, description = result[:test]
            # TODO - use Test#name
            @output.puts "PENDING: #{[contexts<<description].join(" ")}"
          end
        end
      end

    end

  end
end
