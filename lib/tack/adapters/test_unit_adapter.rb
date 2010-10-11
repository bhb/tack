if RUBY_VERSION=~/1.9/
  gem 'test-unit', '~> 1.0'
end
require 'test/unit'
require 'test/unit/testresult'

::Test::Unit.run = true

module Tack

  module Adapters

    class TestUnitAdapter < Adapter

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

      def run_test(path, contexts, description)
        # TODO - since each test is unique, I think 
        # that it's not necessary to return a full result set, 
        # just a result. That might simplify things
        results = Tack::ResultSet.new
        test_classes_for(path).each do |klass|
          if klass.to_s==contexts.first
            run_tests_for_class(klass, path, contexts, description, results)
          end
        end
        basics(results)
      end

      private

      def run_tests_for_class(klass, path, contexts, description, results)
        begin
          test = klass.new(description)
        rescue NameError
          raise NoMatchingTestError, Tack::Util::Test.new(path,contexts,description) 
        end
        result = ::Test::Unit::TestResult.new

        result.add_listener(::Test::Unit::TestResult::FAULT) do |failure|
          results.failed << build_result(path, contexts, description, failure)
        end
        
        test.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
        if result.passed?
          results.passed << build_result(path, contexts, description)
        end
      end
      
      def build_result(file, contexts, description, failure=nil)
        { :test => [file.to_s, contexts, description],
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

      def test_classes_for(test_file)
        @test_classes ||= TestClassDetector.test_classes_for(test_file) do |test_file|
          require test_file
        end
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
