module Tack

  class Reverse
    include Middleware
    
    def run_suite(tests)
      puts "--> Reversing order of tests"
      @app.run_suite(tests.reverse) 
    end

  end

end
