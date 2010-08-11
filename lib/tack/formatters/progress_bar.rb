module Tack

  module Formatters

    class ProgressBar
      include Middleware

      def initialize(middleware, options={})
        super
        @output = options.fetch(:output) {STDOUT}
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do 
          @output.puts
        end
      end

      def run_test(file, context, description)
        returning @app.run_test(file, context, description) do |result|
          result[:passed].each do
            @output.print "."
          end
          result[:pending].each do
            @output.print "P"
          end
          result[:failed].each do
            @output.print "F"
          end
        end
      end
      
    end

  end

end
