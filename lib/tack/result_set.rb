module Tack

  class ResultSet

    attr_accessor :passed, :failed, :pending

    def initialize(results)
      @passed = results.fetch(:passed).map { |result| Result.new(result) }
      @failed = results.fetch(:failed).map { |result| Result.new(result) }
      @pending = results.fetch(:pending).map { |result| Result.new(result) }
    end

    def length
      @passed.length + @failed.length + @pending.length
    end

  end

end
