module Tack

  module Formatters

    class Newline
      include Middleware

      def initialize(app, args={})
        @app = app
        @times = args.fetch(:times) { 1 }
      end
      
      def run_suite(tests)
        returning @app.run_suite(tests) do
          @times.times do 
            puts "\n"
          end
        end
      end

    end

  end

end
