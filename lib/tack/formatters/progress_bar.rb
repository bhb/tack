

module Tack

  module Formatters

    class ProgressBar
      include Middleware::Base

      PASSED = '.'
      PENDING = 'P'
      FAILED = 'F'

      def initialize(app, options = {})
        super
        @verbose = options.fetch(:verbose) { false }
        # TODO - for perf and for correctness, don't set 
        # the sync variable blindly. Use start/restore (commented out below)
        # to either set it for each test or for each suite
        @output.sync = TRUE
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do 
          @output.puts
        end
      end

      def run_test(test)
        returning @app.run_test(test) do |result|
          if @verbose
            @output.print("#{Tack::Util::Test.new(test).name}: ")
          end
          print_char_for_results(result[:passed], PASSED)
          print_char_for_results(result[:pending], PENDING)
          print_char_for_results(result[:failed], FAILED)
          if @verbose
            @output.print("\n")
          end
        end
      end

      private

      #def start_sync_output
      #    @old_sync, output.sync = output.sync, true if output_supports_sync
      #end

      #def restore_sync_output
      #  output.sync = @old_sync if output_supports_sync and !output.closed?
      #end

      #def output_supports_sync
      #  output.respond_to?(:sync=)
      #end


      def print_char_for_results(results, char)
        results.each do
          @output.print(char)
        end
      end
      
    end

  end

end
