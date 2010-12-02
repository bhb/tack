

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
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do 
          @output.puts
        end
      end

      def run_test(test)
        returning @app.run_test(test) do |result|
          set_sync(true) do
            if @verbose
              @output.print("#{Tack::Util::Test.new(test).name}: ")
            end
            print_char(result)
            if @verbose
              @output.print("\n")
            end
          end
        end
      end

      private
      
      def set_sync(value)
        start_sync_output(value)
        yield
      ensure
        restore_sync_output
      end

      def start_sync_output(value)
        @old_sync, @output.sync = @output.sync, value if output_supports_sync?
      end

      def restore_sync_output
        @output.sync = @old_sync if output_supports_sync? and !@output.closed?
      end
      
      def output_supports_sync?
        @output.respond_to?(:sync=)
      end

      def print_char(result)
        char = case result[:status]
               when :passed
                 PASSED
               when :failed
                 FAILED
               when :pending
                 PENDING
               else 
                 raise "Unknown result status #{result[:status]}"
               end
        @output.print(char)
      end
      
    end

  end

end
