module Tack

  class TestSet
    
    def initialize(root_dir)
      @root_dir = root_dir
    end

    def tests_for(path)
      adapter = Adapter.for(path)
      files = Dir[path]
      files.inject([]) do |tests, file|
        tests += adapter.tests_for(file)
      end
    end

  end

end
