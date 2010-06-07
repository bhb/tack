module Tack

  module Formatters

    class PrintFailures
      include Middleware

      def initialize(app)
        @app = app
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          results[:failed].each_with_index do |result, index|
            print_failure(index+1, result)
          end
        end

      end

      private

      def print_failure(counter, result)
        puts
        puts "#{counter.to_s})"
        puts result[:description]
      end

    end

  end

end
