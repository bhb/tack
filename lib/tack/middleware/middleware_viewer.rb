module Tack

  module Middleware

    class MiddlewareViewer
      include Middleware::Base
      
      def run_suite(tests)
        # Just figure print out the middleware stack
        # and return an empty result set
        middlewares = discover_middlewares
        middlewares.each do |middleware|
          @output.puts middleware.class
        end
        {}
      end

      private

      def discover_middlewares
        middleware_chain = [self]
        current = self
        while middleware?(middleware = current.app)
          middleware_chain << middleware
          current = middleware
        end
        middleware_chain
      end

    end

  end

end
