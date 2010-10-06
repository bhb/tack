module Tack

  class StubAdapter
    
    def initialize(mapping={})
      @mapping = {}
      mapping.each do |key, value|
        @mapping[basics(key)] = value
      end
      yield self if block_given?
    end

    def pass(test)
      @mapping[test] = :pass
    end

    def fail(test, message = "Default failure message", backtrace = [])
      @mapping[test] = [:fail, message, backtrace]
    end
    
    def pend(test)
      @mapping[test] = :pend
    end
    
    def run_suite(tests)
      # TODO - this won't work in the general case
      # but it's good enough to get to the next step.
      # The right thing is to refactor the run_suite method
      # out of runner and into an Adapter base class
      results = ResultSet.new
      tests.each do |test|
        result = run_test(*test)
        results.merge(result)
      end
      basics(results)
    end
    
    # TODO - this doesn't actually have the same interface
    # as real adapters yet (should change real adapters)
    def run_test(path,contexts,description)
      test = [path,contexts,description]
      result = @mapping[test]
      raise "No stubbed result for #{test.inspect}" if result.nil?
      status, message, backtrace = result
      case status
      when :pass
        ResultSet.new(:passed => [Result.new(:test => test)]).to_basics
      when :pend
        ResultSet.new(:pending => [Result.new(:test => test)]).to_basics
      when :fail
        ResultSet.new(:failed => [Result.new(:test => test, 
                                             :failure => { :message => message, 
                                               :backtrace => backtrace})]).to_basics
      else
        raise "Unknown status #{status}"
      end
    end

  end

end

