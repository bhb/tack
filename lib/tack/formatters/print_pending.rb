module Tack
  
  module Formatters

    class PrintPending
      include Middleware::Base

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          results[:pending].each do |result|
            path, contexts, description = result[:test]
            @output.puts "PENDING: #{Tack::Util::Test.new(path,contexts,description).name}"
          end
        end
      end

    end

  end
end
