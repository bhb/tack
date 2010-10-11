module Tack

  module Middleware

    module Base
      
      def initialize(app, options = {})
        @app = app
        if @app.is_a?(Adapters::Adapter)
          @app.root = self
        end
        @output = options.fetch(:output){ STDOUT }
      end

      def run_suite(tests)
        @app.run_suite(tests)
      end

      def run_test(file, contexts, description)
        @app.run_test(file, contexts, description)
      end

      # not necessary for the middleware API, but handy for 
      # implementing middleware methods
      def returning(value)
        yield(value)
        value
      end

    end

  end

end
