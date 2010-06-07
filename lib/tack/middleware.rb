module Tack

  module Middleware
    
    def run_suite(tests)
      @app.run_suite(tests)
    end

    def run_test(file, description)
      @app.run_test(file, description)
    end

    # not necessary for the middleware API, but handy for implementing
    # middleware methods
    def returning(value)
      yield(value)
      value
    end

  end

end
