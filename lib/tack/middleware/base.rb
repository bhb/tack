module Tack

  module Middleware

    module Base

      attr_reader :app
      
      def initialize(app, options = {})
        @app = app
        if @app.is_a?(Adapters::Adapter)
          @app.root = self
        end
        @output = options.fetch(:output){ STDOUT }
      end

      # Middleware must implement #run_suite or inherit a sane 
      # implementation like this one.
      def run_suite(tests)
        @app.run_suite(tests)
      end

      # Middleware must implement #run_test or inherit a sane
      # implementation like this one.
      def run_test(test)
        @app.run_test(test)
      end

      # Not necessary, just useful
      def middleware?(obj)
        obj.respond_to?(:run_suite) && obj.method(:run_suite).arity == 1 &&
        obj.respond_to?(:run_test) && obj.method(:run_test).arity == 1 &&
          obj.respond_to?(:app) && !obj.app.nil?
      end

      # Not necessary for the middleware API, but handy for 
      # implementing middleware methods
      def returning(value)
        yield(value)
        value
      end

    end

  end

end
