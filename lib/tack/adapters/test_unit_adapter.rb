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
#puts "--- before tests_for"
#puts "collections: #{GC.collections}"
#puts "live objects #{ObjectSpace.live_objects}"
#puts "all objects #{ObjectSpace.allocated_objects}"
        #require file
        classes = test_classes_for(file)
#puts "--- after test_classes_for"
#puts "collections: #{GC.collections}"
#puts "live objects #{ObjectSpace.live_objects}"
#puts "all objects #{ObjectSpace.allocated_objects}"
        tests = []
        classes.each do |klass|
          # There may be many tests, so try to avoid
          # creating too many objects within the call to #map
          file_name = file.to_s
          context = [klass.to_s]
          tests_for_class = test_methods(klass).map {|method_name| [file_name, context, method_name]}
          if tests_for_class.empty?
            tests_for_class << [file.to_s, [klass.to_s], 'default_test']
          end
          tests += tests_for_class
        end
#puts "--- after tests_for"
#puts "collections: #{GC.collections}"
#puts "live objects #{ObjectSpace.live_objects}"
#puts "all objects #{ObjectSpace.allocated_objects}"
        tests
      end

      def run_test(path, contexts, description)
        # TODO - since each test is unique, I think 
        # that it's not necessary to return a full result set, 
        # just a result. That might simplify things
#        puts "1. all objects #{ObjectSpace.allocated_objects}"
#        puts "1.5 all objects #{ObjectSpace.allocated_objects}"
#        puts "1.55 all objects #{ObjectSpace.allocated_objects}"
        results = Tack::ResultSet.new
 #       puts "2. all objects #{ObjectSpace.allocated_objects}"
        test_classes_for(path).each do |klass|
 #         puts "3. all objects #{ObjectSpace.allocated_objects}"
          if klass.to_s==contexts.first
 #           puts "4. all objects #{ObjectSpace.allocated_objects}"
           run_tests_for_class(klass, path, contexts, description, results)
 #           puts "5. all objects #{ObjectSpace.allocated_objects}"
          end
        end
  #      puts "6. all objects #{ObjectSpace.allocated_objects}"
        x = basics(results)
  #      puts "7. all objects #{ObjectSpace.allocated_objects}"
        x
      end

      private

      def test_result
        @result ||= ::Test::Unit::TestResult.new
      end

      def reset(result)
        result.instance_variable_get(:@failures).clear
        result.instance_variable_get(:@errors).clear
      end

      def run_tests_for_class(klass, path, contexts, description, results)
 #       old = ObjectSpace.allocated_objects
          ###
        begin
#          puts "4.1 all objects #{ObjectSpace.allocated_objects}"
          test = klass.new(description)
#          puts "4.2 all objects #{ObjectSpace.allocated_objects}"
        rescue NameError
          raise NoMatchingTestError, Tack::Util::Test.new(path,contexts,description) 
        end
#        puts "4.3 all objects #{ObjectSpace.allocated_objects}"
        #result = ::Test::Unit::TestResult.new
        result = test_result
#        puts "4.4 all objects #{ObjectSpace.allocated_objects}"

#        result.add_listener(::Test::Unit::TestResult::FAULT) do |failure|
#          results.failed << build_result(path, contexts, description, failure)
#        end
#        puts "4.5 all objects #{ObjectSpace.allocated_objects}"
        
        test.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
#        puts "4.6 all objects #{ObjectSpace.allocated_objects}"

        if result.passed?
          results.passed << build_result(path, contexts, description)
        else
          failures = result.instance_variable_get(:@failures)
          errors = result.instance_variable_get(:@errors)
          (failures+errors).each do |failure|
            results.failed << build_result(path, contexts, description, failure)
          end
        end
        reset(result)
 #       puts "4.7 all objects #{ObjectSpace.allocated_objects}"
 #       puts "--- difference #{ObjectSpace.allocated_objects-old}"
      end
      
      def build_result(file, contexts, description, failure=nil)
        { :test => [file.to_s, contexts, description],
          :failure => build_failure(failure) }
      end

      # TODO - this is identical to the code in ShouldaAdapter
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

      def test_classes_for(test_file)
        return @test_classes unless @test_classes.nil?
        @test_classes ||= TestClassDetector.test_classes_for(test_file) do |test_file|
          require test_file
        end
      end
      
      def test_methods(test_class)
        test_class.public_instance_methods(true).select do |method_name|
          method = test_class.instance_method(method_name)
          method_name =~ /^test./ && [0,-1].member?(method.arity)
        end
      end

    end

  end

end
