require 'pathname'

module Tack

  module Adapters

    class AdapterDetectionError < RuntimeError; end;

    class Adapter

      def self.file_patterns
        test_unit_file_patterns + rspec_file_patterns
      end

      def self.test_unit_file_patterns
        [/test\.rb$/, /^test_.+\.rb$/]
      end

      def self.rspec_file_patterns
        [/_spec\.rb$/]
      end

      def self.for(path)
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
        return false unless defined?(Shoulda)
        ShouldaAdapter.shoulda_file?(path)
      end

    end

  end

end


