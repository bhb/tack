module Tack

  module Adapters

    class Adapter

      def self.is_shoulda?(path)
       #  is_shoulda = false
#         debugger
#         backup_sym = :TackShouldaConstBackup
#         if Object.const_defined?(:Shoulda)
#           Object.send(:const_set, backup_sym, Object.send(:const_get, :Shoulda))
#           Object.send(:remove_const, :Shoulda)
#         end
        
#         debugger
#         require path
#         if Object.const_defined?(:Shoulda)
#           is_shoulda = true
#         end
#       ensure
#         if Object.const_defined?(backup_sym)
#           Object.send(:const_set, :Shoulda, Object.send(:const_get, backup_sym))
#           Object.send(:remove_const, backup_sym)
#           require 'shoulda'
#         end
#         debugger
#         is_shoulda
        #require path
        ShouldaAdapter.shoulda_file?(path)
      end

      def self.for(path)
        # Using a simple path-based heuristic for now
        case path
        when /test.rb$/
          if Adapter.is_shoulda?(path)
            ShouldaAdapter.new
          else
            TestUnitAdapter.new
          end
        when /spec.rb$/
          RSpecAdapter.new
        else
          raise "Cannot determine an adapter for path #{path}"
        end
      end
    end

  end

end


