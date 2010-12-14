module Tack

  module Middleware

    class DryRun
      include Middleware::Base

      def run_suite(tests)
        mapping = {}
        # Hashes are not ordered in 1.8, so we pull the list of files out separately
        test_paths = []
        tests.each do |test_path, contexts, description|
          test_paths << test_path
          mapping[test_path] ||= []
          mapping[test_path] << Tack::Util::Test.new(test_path,contexts,description).name
        end
        test_paths.uniq!
        test_paths.each do |test_path|
          @output.puts "In #{test_path}:"
          mapping[test_path].each do |full_description|
            @output.puts "    #{full_description}"
          end
        end
        @output.puts "-"*40
        @output.puts "#{test_paths.count} files, #{tests.count} tests"
        {}
      end

    end

  end
  
end
