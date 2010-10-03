module Tack

  module Formatters

    class BacktraceCleaner
      include Middleware::Base

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
        end
      end
      
    end

  end

end
