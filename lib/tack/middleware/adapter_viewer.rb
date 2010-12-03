require 'pathname'

module Tack

  module Middleware

    class AdapterViewer
      include Middleware::Base
      include Adapters

      def run_suite(tests)
        paths = []
        tests.each do |path, _, _|
          paths << path.to_s
        end
        paths.uniq!
        paths.sort_by {|path| path.length}
        paths_to_adapters = {}
        paths.each do |path|
          paths_to_adapters[path] = Adapter.for(path).class
        end
        paths_to_adapters = consolidate(paths_to_adapters)
        paths_to_adapters.each do |path, klass|
          if File.directory?(path)
            @output.puts "All files in directory #{path} use #{klass}"
          else
            @output.puts "#{path} uses #{klass}"
          end
        end
        Adapter.reset_cache
        ResultSet.new.to_basics
      end

      private 

    def consolidate(mapping)
      old_num_keys = mapping.keys.length
      parent_to_paths = {}
      mapping.keys.each do |path|
        parent_to_paths[Pathname(path).parent] ||= []
        parent_to_paths[Pathname(path).parent] << path
      end
      parent_to_paths.each do |parent, paths|
        first_adapter = mapping[paths.first] #Adapter.for(paths.first).class
        if paths.all? { |path| first_adapter == mapping[path] }
          paths.each do |path|
            mapping.delete(path)
          end
          mapping[parent] = first_adapter
        end
      end
      new_num_keys = mapping.keys.length 
      if old_num_keys == new_num_keys || new_num_keys <= 1
        mapping
      else
        consolidate(mapping)
      end
    end

    def print(mapping)
    end

  end

  end
end
