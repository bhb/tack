

module Tack

  module Formatters

    class ProgressBar
      include Middleware::Base

      def initialize(app, options = {})
        super
        @verbose = options.fetch(:verbose) { false }
        @output.sync = TRUE
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do 
          @output.puts
        end
      end

      def run_test(file, contexts, description)
        returning @app.run_test(file, contexts, description) do |result|
          if @verbose
            @output.print("#{Tack::Util::Test.new(file,contexts,description).name}: ")
          end
          print_char_for_results(result[:passed], '.')
          print_char_for_results(result[:pending], 'P')
          print_char_for_results(result[:failed], 'F')
          if @verbose
            @output.print("\n")
          end
        end
      end

      private

      def print_char_for_results(results, char)
        results.each do
          @output.print(char)
        end
      end
      
    end

  end

end
