require 'pathname'

module Tack

  module Adapters

    class AdapterDetectionError < RuntimeError; end;

    class Adapter

      attr_accessor :root

      def initialize(root = self)
        # 'root' is the topmost application in the chain
        # of middlewares and adapters. All chains start 
        # with zero or more adapters followed by exactly
        # one adapter
        @root = root
      end

      def run_suite(tests)
        results = Util::ResultSet.new
        tests.each do |test|
          result = @root.run_test(test)
          #results.merge(result)
          results << result
        end
        basics(results)
      end

      # Adapters can optionally sort the complete list of tests from all files.
      # The default behavior is to do nothing.
      def order(tests)
        tests
      end

      def self.file_patterns
        test_unit_file_patterns + rspec_file_patterns
      end

      def self.test_unit_file_patterns
        [/test\.rb$/, /^test_.+\.rb$/]
      end

      def self.rspec_file_patterns
        [/_spec\.rb$/]
      end

      # for testing
      def self.reset_cache
        @adapters = {}
      end

      # TODO : This should probably be an instance method
      # because the adapter cache currrently needs to be reset
      # for each test
      def self.for(path)
        path = path.to_s
        @adapters ||= {}
        return @adapters[path] if @adapters.key?(path)
        # Using a simple path-based heuristic for now
        case Pathname.new(path).basename.to_s
        when *test_unit_file_patterns
          if shoulda_file?(path)
            @adapters[path]=ShouldaAdapter.new
          elsif mini_test_shim?(path)
            @adapters[path]=MiniTestShimAdapter.new
          else
            @adapters[path]=TestUnitAdapter.new
          end
        when *rspec_file_patterns
          @adapters[path]=RSpecAdapter.new
        else
          raise AdapterDetectionError, "Cannot determine a test adapter for file #{path.inspect}"
        end
      end

      def self.mini_test_shim?(path)
        @mt_cache ||= {}
        if @mt_cache.has_key?(path)
          return @mt_cache[path]
        end

        sandbox = ForkedSandbox.new
        result = sandbox.run do
          require path
          result = defined?(MiniTest)
          @mt_cache[path] = result
        end
        result
      end

      def self.shoulda_file?(path)
        @shoulda_cache ||= {}
        if @shoulda_cache.has_key?(path)
          return @shoulda_cache[path]
        end

        sandbox = ForkedSandbox.new
        result = sandbox.run do
          require path
          result = defined?(Shoulda) && ShouldaAdapter.shoulda_file?(path)
          @shoulda_cache[path] = result
        end
        result
      end

    end

  end

end


