module Tack

  class TestSet
    
    def initialize(root_dir)
      @root_dir = root_dir
    end

    def tests_for(path, pattern=TestPattern.new)
      adapter = Adapters::Adapter.for(path)
      files = Dir[path]
      files.inject([]) do |tests, file|
        tests += adapter.tests_for(file, pattern)
      end
    end

  end

end
