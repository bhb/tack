module Tack

  module Formatters

    class ProgressBar

      def initialize(app)
        @app = app
      end

      def run_suite(tests)
        results = @app.run_suite(tests)
        puts
        results
      end

      def run_test(file, description)
        result = @app.run_test(file, description)
        result[:passed].each do
          print "."
        end
        result[:pending].each do
          print "P"
        end
        result[:failed].each do
          print "F"
        end
        result
      end
      
    end

  end

end
