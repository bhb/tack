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
    
    def run_test(test)
      result = @mapping[test]
      raise "No stubbed result for #{test.inspect}" if result.nil?
      status, message, backtrace = result
      case status
      when :pass
        Result.new(:status => :passed, :test => test).to_basics
      when :pend
        Result.new(:status => :pending, :test => test).to_basics
      when :fail
        Result.new(:status => :failed, 
                   :test => test,
                   :failure => 
                   { :message => message,
                     :backtrace => backtrace }
                     ).to_basics
      else
        raise "Unknown status #{status}"
      end
    end

  end

end

