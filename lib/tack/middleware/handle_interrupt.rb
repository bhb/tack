module Tack

  module Middleware

    class HandleInterrupt
      include Middleware::Base

      def initialize(app,args={})
        super
        @results = Tack::ResultSet.new
      end

      def run_suite(tests)
        trap("INT") do
          @output.puts "\n\nInterrupted. Finishing up.\n\n"
          return @results.to_basics
        end
        @app.run_suite(tests)
      end
      
      def run_test(file, contexts, description)
        returning @app.run_test(file, contexts, description) do |result|
          @results.merge(result)
        end
      end
      
    end
    
  end

end
