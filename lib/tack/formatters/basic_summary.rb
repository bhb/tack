module Tack

  module Formatters

    class BasicSummary
      include Middleware

      def initialize(app)
        @app = app
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          puts "%d tests, %d failures, %d pending" % [results.values.flatten.length, results[:failed].length, results[:pending].length]
        end
      end
      
    end

  end

end
