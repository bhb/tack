if RUBY_VERSION=~/1.9/
  gem 'test-unit', '~> 1.0'
end
require 'test/unit'
require 'test/unit/testresult'

Test::Unit.run = true

require 'shoulda'
module Shoulda

  # Just here for testing purposes to see if this has been defined
  module Tack
  end

  class << self
    
    attr_accessor :all_contexts

    alias_method :original_add_context, :add_context
    
    def all_contexts
      @all_contexts ||= []
    end

    def add_context(context)
      all_contexts << context unless context.am_subcontext?
      original_add_context(context)
    end

  end
  
end

module Tack

  module Adapters

    class ShouldaAdapter

      def self.shoulda_file?(path)
        require path
        test_classes = self.test_classes_for(path)
        return false if test_classes.empty?
        test_classes.any? do |klass|
          test_methods = self.test_methods(klass)
          test_methods.any? do |test_method|
            test_method =~ /^test\: .*\. $/
          end
        end
      end

      def tests_for(file)
        require file
        classes = self.class.test_classes_for(file)
        classes.inject([]) do |tests, klass|
          contexts = Shoulda.all_contexts.select { |context| context.parent == klass }
          contexts.each do |context|
            tests += get_tests(file,context)
          end
          tests
        end
      end

      def get_tests(file, context) 
        tests = []
        context.shoulds.each do |should|
          tests << [file, ancestors(context), should[:name]]
        end
        context.subcontexts.each do |subcontext|
          tests += get_tests(file, subcontext)
        end
        tests
      end

      def ancestors(context)
        ancestors = [context.name]
        parent = context
        until ((parent=parent.parent).is_a? Class)
          ancestors.unshift(parent.name)
        end
        ancestors.reject! {|context_name| context_name + "Test" == parent.to_s}
        [parent.to_s] + ancestors
      end

      def get_context_names(klass)
        contexts = Shoulda.all_contexts.select { |context| context.parent == klass }
        contexts.inject [klass.to_s] do |context_names, context|
          
        end
      end

      def for_subcontexts(context)
        context.subcontexts.each do |subcontext|
          yield subcontext if block_given?
        end
      end

      def run(path, context, description)
        results = { :passed => [],
          :failed => [],
          :pending => []}
        require(path)
        # Note that this won't work if there are multiple classes in a file
        klass = self.class.test_classes_for(path).first 

        test = klass.new(test_name([path,context,description]))
        result = Test::Unit::TestResult.new

        result.add_listener(Test::Unit::TestResult::FAULT) do |failure|
          results[:failed] << build_result(test_name([path, context, description]), failure)
        end
        
        test.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
        if result.passed?
          results[:passed] << build_result(test_name([path,context,description]))
        end
        results
      end

      private

      def test_name(test)
        _, contexts, description = test
        if contexts.length == 1
          class_under_test = contexts.first.gsub(/Test/,'')
          context_description = class_under_test
        else
          context_description = (contexts[1..-1] || []).join(" ")          
        end
        ["test:", context_description, "should", "#{description}. "].join(" ")
      end
      
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

      def self.test_classes_for(file)
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

      def self.test_methods(test_class)
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
