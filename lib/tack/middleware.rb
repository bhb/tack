module Tack

  module Middleware
    
    def initialize(app, options = {})
      @app = app
      @output = options.fetch(:output){ STDOUT }
    end

    def run_suite(tests)
      @app.run_suite(tests)
    end

    def run_test(file, context, description)
      @app.run_test(file, context, description)
    end

    # not necessary for the middleware API, but handy for 
    # implementing middleware methods
    def returning(value)
      yield(value)
      value
    end

  end

end
