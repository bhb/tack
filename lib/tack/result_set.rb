module Tack

  class ResultSet

    attr_accessor :passed, :failed, :pending

    def initialize(results={})
      @passed = results.fetch(:passed){[]}.map { |result| Result.new(result) }
      @failed = results.fetch(:failed){[]}.map { |result| Result.new(result) }
      @pending = results.fetch(:pending){[]}.map { |result| Result.new(result) }
    end

    def length
      @passed.length + @failed.length + @pending.length
    end

    def to_primitives
      { :passed => passed.map {|x| result_to_primitives(x)},
        :failed => failed.map{|x| result_to_primitives(x)},
        :pending => pending.map{|x| result_to_primitives(x)} }
    end

    def merge(results)
      new_results = ResultSet.new(results)
      self.passed += new_results.passed
      self.failed += new_results.failed
      self.pending += new_results.pending
    end

    private

    def result_to_primitives(result)
      if result.respond_to?(:to_primitives)
        result.to_primitives
      else
        result
      end
    end
    
  end

end
