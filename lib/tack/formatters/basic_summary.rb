module Tack

  module Formatters

    class BasicSummary
      include Middleware

      def initialize(app)
        @app = app
      end

      def run_suite(tests)
        results = @app.run_suite(tests)
        puts "%d tests, %d failures, %d pending" % [results.values.flatten.length, results[:failed].length, results[:pending].length]
        results
      end
      
    end

  end

end
