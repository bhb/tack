module Tack

  class Runner
    
    def initialize(root_dir)
      @root_dir = root_dir
    end

    def run(tests)
      #adapter = Adapter.for(@root_dir)
      #adapter.run(tests)
      results = { :passed => [],
        :failed => [],
        :pending => []}
      tests.each do |path, description|
        adapter = Adapter.for(path)
        results[:passed] += adapter.run(path, description)[:passed]
        results[:failed] += adapter.run(path, description)[:failed]
        results[:pending] += adapter.run(path, description)[:pending]
      end
      results
    end

  end


end
