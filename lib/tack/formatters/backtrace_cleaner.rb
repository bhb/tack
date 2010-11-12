module Tack

  module Formatters

    class BacktraceCleaner
      include Middleware::Base

      def initialize(app, opts = {})
        if opts.fetch(:full){false} 
          @backtrace_cleaner = nil
        else
          @backtrace_cleaner = ::Tack::Formatters::QuietBacktrace::BacktraceCleaner.new
          @backtrace_cleaner.add_silencer { |line| line=~%r{bin/tack}}
          @backtrace_cleaner.add_silencer { |line| line=~%r{lib/tack}}
          @backtrace_cleaner.add_silencer { |line| line=~%r{lib/spec}}
        end
        super
      end

      def run_test(test)
        returning @app.run_test(test) do |result|
          if @backtrace_cleaner && !result[:failed].empty?
            # TODO - this is evidence that the object returned by run_test is too complex
            backtrace = result[:failed].first[:failure][:backtrace].clone
            backtrace = @backtrace_cleaner.clean(backtrace) 
            result[:failed].first[:failure][:backtrace] = backtrace
          end
        end
      end
      
    end

  end

end
