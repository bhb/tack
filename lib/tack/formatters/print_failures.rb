module Tack

  module Formatters

    class PrintFailures
      include Middleware

      def run_suite(tests)
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
        puts
        puts "#{counter.to_s})"
        puts full_description(result[:test])
        puts format_backtrace(result[:failure][:backtrace])
        puts result[:failure][:message]
      end

      def full_description(test)
        _, contexts, description = test
        "(#{contexts.first}) #{contexts[1..-1].join(" ")} should #{description}"
      end

    end

  end

end
