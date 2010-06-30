module Tack

  class TestSet
    
    def initialize(adapter=nil)
      @adapter = adapter
    end

    def tests_for(paths, pattern=TestPattern.new)
      paths = Array(paths).map { |path| path.to_s}
      files = paths.inject([]) do |files, path|
        if File.directory?(path)
          files += Dir[File.join(path,"**/*")].select {|f| valid_test_file?(f)}
        else
          files << path
        end
      end

      files.inject([]) { |tests, file|
        adapter = @adapter || Adapters::Adapter.for(file)
        tests += adapter.tests_for(file).select  do |_, contexts, description| 
          contexts = Array(contexts)
          description.match(pattern) || contexts.any? {|x| x.match(pattern)}
        end
      }
    end

    private 

    def valid_test_file?(path)
      return false if File.directory?(path)
      case path
      when /_test.rb$/, /_spec.rb$/
          true
      else
        false
      end
    end

  end

end
