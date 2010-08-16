module Tack

  module Middleware

    class Reverse
      include Middleware::Base
      
      def run_suite(tests)
        @output.puts "--> Reversing order of tests"
        @app.run_suite(tests.reverse) 
      end

    end

  end

end
