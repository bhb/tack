module Tack

  class NoMatchingTestError < RuntimeError

    def initialize(test)
      super("Could not find test \"#{test.name}\" in #{test.file}")
    end

  end

end
