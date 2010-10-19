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
        results = ResultSet.new
        tests.each do |path, contexts, description|
          result = @root.run_test(path, contexts, description)
          results.merge(result)
        end
        basics(results)
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
        case Pathname.new(path).basename
        when *test_unit_file_patterns
          if shoulda_file?(path)
            @adapters[path]=ShouldaAdapter.new
          else
            @adapters[path]=TestUnitAdapter.new
          end
        when *rspec_file_patterns
          @adapters[path]=RSpecAdapter.new
        else
          raise AdapterDetectionError, "Cannot determine a test adapter for file #{path}"
        end
      end

      def self.shoulda_file?(path)
        sandbox = ForkedSandbox.new
        sandbox.run do
          require path
          defined?(Shoulda) && ShouldaAdapter.shoulda_file?(path)
        end
      end

    end

  end

end


