if RUBY_VERSION=~/1.9/
  gem 'test-unit', '~> 1.0'
end
require 'test/unit'
require 'test/unit/testresult'

::Test::Unit.run = true

module Tack

  module Adapters

    class TestUnitAdapter

      def initialize
      end

      def tests_for(file)
        #require file
        classes = test_classes_for(file)
        tests = []
        classes.each do |klass|
          tests_for_class = test_methods(klass).map {|method_name| [file.to_s, [klass.to_s], method_name.to_s]}
          if tests_for_class.empty?
            tests_for_class << [file.to_s, [klass.to_s], 'default_test']
          end
          tests += tests_for_class
        end
        tests
      end

      def run(path, context, description)
        results = Tack::ResultSet.new
        test_classes_for(path).each do |klass|
          if klass.to_s==context.first
            run_tests_for_class(klass, path, context, description, results)
          end
        end
        basics(results)
      end

      private

      def run_tests_for_class(klass, path, context, description, results)
        begin
          test = klass.new(description)
        rescue NameError
          raise NoMatchingTestError, "No matching test found" 
        end
        result = ::Test::Unit::TestResult.new

        result.add_listener(::Test::Unit::TestResult::FAULT) do |failure|
          results.failed << build_result(path, context, description, failure)
        end
        
        test.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
        if result.passed?
          results.passed << build_result(path, context, description)
        end
      end
      
      def build_result(file, context, description, failure=nil)
        { :test => [file.to_s, context, description],
          :failure => build_failure(failure) }
      end

      def build_failure(failure)
        return nil if failure.nil?
        case failure
        when ::Test::Unit::Error
          { :message => "#{failure.exception.class} was raised: #{failure.exception.message}",
            :backtrace => failure.exception.backtrace }
        else
          { :message => failure.message,
            :backtrace => failure.location }
        end
      end

#       def test_classes_for(file)
#         # taken from from hydra
#         #code = ""
#         #    File.open(file) {|buffer| code = buffer.read}
#         code = File.read(file)
#         matches = code.scan(/class\s+([\S]+)/)
#         klasses = matches.collect do |c|
#           begin
#             if c.first.respond_to? :constantize
#               c.first.constantize
#             else
#               eval(c.first)
#             end
#           rescue NameError
#             # means we could not load [c.first], but thats ok, its just not
#             # one of the classes we want to test
#             nil
#           rescue SyntaxError
#             # see above
#             nil
#           end
#         end
#         return klasses.select{|k| k.respond_to? 'suite'}
#       end

      def test_classes_for(test_file)
        @test_classes ||= begin
        # TODO - I think this will fail if they have a file that doesn't define a new class
        # for instance, if they are adding methods to an existing test class
                            old_test_classes = get_test_classes
                            require test_file
                            new_test_classes = get_test_classes
                            new_test_classes - old_test_classes
                          end
      end
      
      def get_test_classes
        test_classes = []
        ObjectSpace.each_object(Class) do |klass|
          if(Test::Unit::TestCase > klass)
            test_classes << klass
          end
        end
        test_classes
      end

      def test_methods(test_class)
        test_class.instance_methods.select do |method_name|
          method_name =~ /^test./ &&
            (test_class.instance_method(method_name).arity == 0 ||
             test_class.instance_method(method_name).arity == -1
             )
        end
      end

    end

  end

end
