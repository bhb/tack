module Tack

  module Middleware

    class Fork
      include Middleware::Base
      
      def run_test(test)
        @reader, @writer = IO.pipe
        if @child = fork
          proceed_as_parent
        else
          proceed_as_child(test)
        end
      end

      private
      
      def proceed_as_child(test)
        @reader.close
        result = @app.run_test(test)
        Marshal.dump([:ok, result], @writer)
      rescue Object => error
        Marshal.dump([
                      :error,
                      [error.class, error.message, error.backtrace]],
                     @writer)
      ensure
        @writer.close
        exit! error ? 1 : 0
      end

      def proceed_as_parent
        @writer.close
        Process.wait(@child)
        status, result = Marshal.load(@reader)
        case status
        when :ok
          result
        when :error
          error_class, error_message, backtrace = result
          error = error_class.new(error_message)
          error.set_backtrace(backtrace)
          raise error
        else
          raise "Unknown status #{status}"
        end
      ensure
        @reader.close
      end

    end

  end

end
