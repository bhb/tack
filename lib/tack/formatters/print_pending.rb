module Tack
  
  module Formatters

    class PrintPending
      include Middleware

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          results[:pending].each do |result|
            file, context, description = result[:test]
            @output.puts "PENDING: #{[context<<description].join(" ")}"
          end
        end
      end

    end

  end
end
