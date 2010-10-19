require 'pathname'

module Tack

  module Middleware

    class AdapterViewer
      include Middleware::Base
      include Adapters

      def run_suite(tests)
        files = []
        tests.each do |file, _, _|
          files << file.to_s
        end
        files.uniq!
        files.sort_by {|file| file.length}
        files_to_adapters = {}
        files.each do |file|
          files_to_adapters[file] = Adapter.for(file).class
        end
        files_to_adapters = consolidate(files_to_adapters)
        files_to_adapters.each do |file, klass|
          if File.directory?(file)
            @output.puts "All files in directory #{file} use #{klass}"
          else
            @output.puts "#{file} uses #{klass}"
          end
        end
        Adapter.reset_cache
        ResultSet.new.to_basics
      end

      private 

    def consolidate(mapping)
      old_num_keys = mapping.keys.length
      parent_to_files = {}
      mapping.keys.each do |file|
        parent_to_files[Pathname(file).parent] ||= []
        parent_to_files[Pathname(file).parent] << file
      end
      parent_to_files.each do |path, files|
        first_adapter = mapping[files.first] #Adapter.for(files.first).class
        if files.all? { |file| first_adapter == mapping[file] }
          files.each do |file|
            mapping.delete(file)
          end
          mapping[path] = first_adapter
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
