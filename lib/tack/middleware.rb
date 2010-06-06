module Tack

  module Middleware
    
    def run_suite(tests)
      @app.run_suite(tests)
    end

    def run_test(file, description)
      @app.run_test(file, description)
    end

  end

end
