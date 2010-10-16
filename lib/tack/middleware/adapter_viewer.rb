require 'pathname'

module Tack

  module Middleware

    class AdapterViewer
      include Middleware::Base
      include Adapters

      def run_suite(tests)
        files = []
        tests.each do |file, _, _|
          files << file
        end
        files.uniq!
        files.sort_by {|file| file.length}
        files_to_adapters = {}
        files.each do |file|
          files_to_adapters[file] = Adapter.for(file).class
        end
        files_to_adapters.each do |file, klass|
          @output.puts "#{file} will use #{klass}"
        end
        ResultSet.new.to_basics
      end

    end

  end
end
