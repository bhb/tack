module Tack

  module Formatters

    class Newline
      include Middleware::Base

      def initialize(app, args={})
        @app = app
        @times = args.fetch(:times) { 1 }
        @output = args.fetch(:output) {STDOUT}
      end
      
      def run_suite(tests)
        returning @app.run_suite(tests) do
          @times.times do 
            @output.puts "\n"
          end
        end
      end

    end

  end

end
