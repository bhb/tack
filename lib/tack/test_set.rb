require 'pathname'

module Tack

  class TestSet
    
    def initialize(adapter=nil)
      @adapter = adapter
    end

    def tests_for(paths, patterns = [])
      patterns = Array(patterns)
      patterns = [TestPattern.new] if patterns.empty?
      paths = Array(paths).map { |path| path.to_s}
      paths = paths.inject([]) do |paths, path|
        if File.directory?(path)
          paths += Dir[File.join(path,"**/*")].select {|f| valid_test_file?(f)}
        else
          paths << path
        end
      end

      paths.inject([]) { |tests, path|
        adapter = @adapter || Adapters::Adapter.for(path)
        tests += adapter.tests_for(path).select  do |_, contexts, description| 
          contexts = Array(contexts)
          patterns.any? do |pattern|
            Util::Test.new(path,contexts,description).name.match(pattern)
          end
        end
      }
    end

    private 
    
    def valid_test_file?(path)
      return false if File.directory?(path)
      case Pathname.new(path).basename
      when *Adapters::Adapter.file_patterns
          true
      else
        false
      end
    end

  end

end
