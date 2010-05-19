module Tack

  class Runner
    
    def initialize(root_dir)
      @root_dir = root_dir
    end

    def run(tests)
      adapter = RSpecAdapter.new
      adapter.run(tests)
    end

  end


end
