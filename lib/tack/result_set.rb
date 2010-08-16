module Tack

  class ResultSet

    attr_accessor :passed, :failed, :pending

    def initialize(results={})
      # TODO - figure out better way to smartly handle either ResultSet or primitive objects
      results = results.to_primitives if results.respond_to?(:to_primitives)
      @passed = result_objects(results[:passed])
      @failed = result_objects(results[:failed])
      @pending = result_objects(results[:pending])
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
    
    def result_objects(results)
      if results == nil
        []
      else
        results.map { |result| Result.new(result) }
      end
    end

    def result_to_primitives(result)
      if result.respond_to?(:to_primitives)
        result.to_primitives
      else
        result
      end
    end
    
  end

end
