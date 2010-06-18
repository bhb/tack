module Tack

  module Formatters

    class ProgressBar
      include Middleware

      def initialize(app)
        @app = app
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do 
          puts
        end
      end

      def run_test(file, context, description)
        returning @app.run_test(file, context, description) do |result|
          result[:passed].each do
            print "."
          end
          result[:pending].each do
            print "P"
          end
          result[:failed].each do
            print "F"
          end
        end
      end
      
    end

  end

end
