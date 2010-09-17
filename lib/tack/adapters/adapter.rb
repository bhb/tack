require 'pathname'

module Tack

  module Adapters

    class Adapter

      def self.for(path)
        @adapters ||= {}
        return @adapters[path] if @adapters.key?(path)
        # Using a simple path-based heuristic for now
        case Pathname.new(path).basename
        when /test\.rb$/,/^test_.+\.rb$/
          if ShouldaAdapter.shoulda_file?(path)
            @adapters[path]=ShouldaAdapter.new
          else
            @adapters[path]=TestUnitAdapter.new
          end
        when /spec\.rb$/
          @adapters[path]=RSpecAdapter.new
        else
          raise "Cannot determine an adapter for path #{path}"
        end
      end
    end

  end

end


