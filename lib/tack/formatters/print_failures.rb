module Tack

  module Formatters

    class PrintFailures
      include Middleware::Base

      def run_suite(tests)
        tests = basics(tests)
        returning @app.run_suite(tests) do |results|
          results[:failed].each_with_index do |result, index|
            print_failure(index+1, result)
          end
        end
      end

      private

      def format_backtrace(backtrace)
        return "" if backtrace.nil?
        "["+backtrace.map { |line| backtrace_line(line) }.join("\n")+"]:"
      end

      def backtrace_line(line)
        line.sub(/\A([^:]+:\d+)$/, '\\1:')
      end

      def print_failure(counter, result)
        @output.puts
        @output.puts "#{counter.to_s})"
        @output.puts full_description(result[:test])
        @output.puts format_backtrace(result[:failure][:backtrace])
        @output.puts result[:failure][:message]
      end

      def full_description(test)
        Tack::Util::Test.new(*test).name
      end

    end

  end

end
