module Tack

  module Formatters

    class TotalTime
      include Middleware::Base

      def run_suite(tests)
        time = Time.now
        returning @app.run_suite(tests) do
          @output.puts "Finished in %.7f seconds." % (Time.now - time)
        end
      end

    end
    
  end

end
