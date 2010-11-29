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
          if @backtrace_cleaner && result[:status]==:failed
            backtrace = result[:failure][:backtrace].clone
            backtrace = @backtrace_cleaner.clean(backtrace) 
            result[:failure][:backtrace] = backtrace
          end
        end
      end
      
    end

  end

end
