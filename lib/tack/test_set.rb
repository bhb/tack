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
      
      paths = paths.map do |path|
        if File.directory?(path)
          Dir[File.join(path,"**/*")].select {|f| valid_test_file?(f)}
        else
          path
        end
      end.flatten

      tests = []
      adapter = nil
      paths.each do |path|
        adapter = @adapter || Adapters::Adapter.for(path)
        tests += adapter.tests_for(path).select  do |_, contexts, description| 
          contexts = Array(contexts)
          patterns.any? do |pattern|
            Util::Test.new(path,contexts,description).name.match(pattern)
          end
        end
      end
      # TODO This won't work if the suite actually uses multiple adapters
      if adapter.respond_to?(:order)
        tests = adapter.order(tests)
      end

      tests
    end

    private 
    
    def valid_test_file?(path)
      return false if File.directory?(path)
      case Pathname.new(path).basename.to_s
      when *Adapters::Adapter.file_patterns
          true
      else
        false
      end
    end

  end

end
