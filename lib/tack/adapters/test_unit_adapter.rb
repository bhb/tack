if RUBY_VERSION=~/1.9/
  gem 'test-unit', '~> 2.3.0'
end
require 'test/unit'
require 'test/unit/testresult'

::Test::Unit.run = true

module Tack

  module Adapters

    class TestUnitAdapter < Adapter

      def tests_for(path)
        classes = test_classes_for(path)
        tests = []
        classes.each do |klass|
          # There may be many tests, so try to avoid
          # creating too many objects within the call to #map
          path_name = path.to_s
          context = [klass.to_s]
          tests_for_class = test_methods(klass).map {|method_name| [path_name, context, method_name]}
          if tests_for_class.empty?
            if klass.public_method_defined?('default_test')
              tests_for_class << [path_name, [klass.to_s], 'default_test']
            end
          end
          tests += tests_for_class
        end
        tests = tests.reject { |_,_,method_name| method_name == 'default_test'} if defined?(Rails)
        tests.sort
      end

      def run_test(test)
        result = nil
        path, contexts, _ = test
        test_classes_for(path).each do |klass|
          if klass.to_s==contexts.first
            result = run_test_for_class(klass, test)
          end
        end
        basics(result)
      end

      def order(tests)
        tests.extend(StableSort).stable_sort
        # Not sure why I wanted to sort by contexts instead of 
        # the full test. Weird. Keeping the code for now to make sure
        # it doesn't break anything
        #sort_by_contexts(tests)
      end

      protected 

      def execute(testcase, test)
        result = ::Test::Unit::TestResult.new
        testcase.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
        if result.passed?
          return build_result(:passed, test) 
        else
          failures = result.instance_variable_get(:@failures)
          errors = result.instance_variable_get(:@errors)
          failure = (failures+errors).first
          return build_result(:failed, test, failure)
        end
      end

      private

#       def sort_by_contexts(tests)
#         tests.extend(StableSort).stable_sort do |stable_test1, stable_test2|
#           test1, stabilizer1 = stable_test1
#           test2, stabilizer2 = stable_test2
#           # Tests are [path, contexts, description]
#           # so test[1] grabs the context for each test
#           [test1[1], stabilizer1] <=> [test2[1], stabilizer2]
#         end
#       end

      def reset(result)
        result.instance_variable_get(:@failures).clear
        result.instance_variable_get(:@errors).clear
      end
      
      def run_test_for_class(klass, test)
        _, _, description = test
        begin
          testcase = klass.new(description)
        rescue NameError
          raise NoMatchingTestError, Tack::Util::Test.new(test)
        end
        result = execute(testcase, test)
        result
      end
      
      def build_result(status, test, failure=nil)
        { :status => status,
          :test => test,
          :failure => build_failure(failure) }
      end

      def build_failure(failure)
        return nil if failure.nil?
        case failure
        when ::Test::Unit::Error
          Tack::Util::TestFailure.new("#{failure.exception.class} was raised: #{failure.exception.message}",
                                      failure.exception.backtrace).to_basics
        else
          Tack::Util::TestFailure.new(failure.message, failure.location).to_basics
        end
      end

      def test_classes_for(path)
        return @test_classes unless @test_classes.nil?
        @test_classes ||= TestClassDetector.test_classes_for(path) do |path|
          require path
        end
      end
      
      def test_methods(test_class)
        include_super = true
        test_class.public_instance_methods(include_super).select do |method_name|
          valid_test_method?(test_class, method_name)
        end
      end

      def valid_test_method?(test_class, method_name)
        method = test_class.instance_method(method_name)
        method_name =~ /^test./ && [0,-1].member?(method.arity)
      end

    end

  end

end
