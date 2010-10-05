module Tack

  class ResultSet

    attr_accessor :passed, :failed, :pending

    def initialize(results={})
      results = basics(results)
      @passed = result_objects(results[:passed])
      @failed = result_objects(results[:failed])
      @pending = result_objects(results[:pending])
    end

    def length
      @passed.length + @failed.length + @pending.length
    end

    def to_basics
      { :passed => passed.map {|x| basics(x)},
        :failed => failed.map{|x| basics(x)},
        :pending => pending.map{|x| basics(x)} }
    end

    def pass(test)
      @passed << Result.for_test(test)
    end

    def fail(test, failure)
      @failed << Result.for_test(test, failure)
    end

    def pend(test)
      @pending << Result.for_test(test)
    end

    def merge(results)
      new_results = ResultSet.new(results)
      self.passed += new_results.passed
      self.failed += new_results.failed
      self.pending += new_results.pending
    end

    private
    
    def result_objects(results)
      if results == nil
        []
      else
        results.map do |result| 
          Result.new(result)
        end
      end
    end

  end

end
