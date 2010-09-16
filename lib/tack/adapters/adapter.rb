require 'pathname'

module Tack

  module Adapters

    class Adapter

      def self.for(path)
        # Using a simple path-based heuristic for now
        case Pathname.new(path).basename
        when /test\.rb$/,/^test_.+\.rb$/
          if ShouldaAdapter.shoulda_file?(path)
            ShouldaAdapter.new
          else
            TestUnitAdapter.new
          end
        when /spec\.rb$/
          RSpecAdapter.new
        else
          raise "Cannot determine an adapter for path #{path}"
        end
      end
    end

  end

end


