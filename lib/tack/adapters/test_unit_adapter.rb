if RUBY_VERSION=~/1.9/
  gem 'test-unit', '~> 1.0'
end
require 'test/unit'
require 'test/unit/testresult'

Test::Unit.run = true

module Tack

  module Adapters

    class TestUnitAdapter

      def tests_for(file, pattern)
        require file
        classes = test_classes_for(file)
        classes.inject([]) do |tests, klass|
          tests += test_methods(klass).map {|method_name| [file, method_name.to_s]}.select {|file, method_name| method_name.match(pattern)}
        end
      end

      def run(path, description)
        results = { :passed => [],
          :failed => [],
          :pending => []}
        require(path)
        # Note that this won't work if there are multiple classes in a file
        klass = test_classes_for(path).first 
        test = klass.new(description)
        result = Test::Unit::TestResult.new

        result.add_listener(Test::Unit::TestResult::FAULT) do |failure|
          results[:failed] << build_result(description, failure)
        end
        
        test.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
        if result.passed?
          results[:passed] << build_result(description)
        end
        results
      end

      private
      
      def build_result(description, failure=nil)
        { :description => description, 
          :failure => build_failure(failure) }
      end

      def build_failure(failure)
        return {} if failure.nil?
        case failure
        when Test::Unit::Error
          { :message => "#{failure.exception.class} was raised: #{failure.exception.message}",
            :backtrace => failure.exception.backtrace }
        else
          { :message => failure.message,
            :backtrace => failure.location }
        end
      end

      def test_classes_for(file)
        # taken from from hydra
        #code = ""
        #    File.open(file) {|buffer| code = buffer.read}
        code = File.read(file)
        matches = code.scan(/class\s+([\S]+)/)
        klasses = matches.collect do |c|
          begin
            if c.first.respond_to? :constantize
              c.first.constantize
            else
              eval(c.first)
            end
          rescue NameError
            # means we could not load [c.first], but thats ok, its just not
            # one of the classes we want to test
            nil
          rescue SyntaxError
            # see above
            nil
          end
        end
        return klasses.select{|k| k.respond_to? 'suite'}
      end

      def test_methods(test_class)
        test_class.instance_methods.select do |method_name|
          method_name =~ /^test./ &&
            (test_class.instance_method(method_name).arity == 0 ||
             test_class.instance_method(method_name).arity == -1
             )
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

    end

  end

end
