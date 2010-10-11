module Tack

  class StubAdapter < Adapters::Adapter
    
    def initialize(mapping={})
      @mapping = {}
      mapping.each do |key, value|
        @mapping[basics(key)] = value
      end
      yield self if block_given?
      super(self)
    end

    def pass(test)
      @mapping[basics(test)] = :pass
    end

    def fail(test, message = "Default failure message", backtrace = [])
      @mapping[basics(test)] = [:fail, message, backtrace]
    end
    
    def pend(test)
      @mapping[basics(test)] = :pend
    end

    def run_suite(tests)
      super(tests.map{|t| basics(t)})
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

