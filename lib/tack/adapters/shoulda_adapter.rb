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

    def reset_contexts!
      @all_contexts = nil
    end

    def add_context(context)
      def context.print_should_eventuallys
        # suppress output
      end
      def context.warn(_)
        # suppress output
      end
      all_contexts << context unless context.am_subcontext?
      original_add_context(context)
    end

  end
  
end

module Tack

  module Adapters

    class ShouldaAdapter

      def self.shoulda_file?(path)
        Shoulda.reset_contexts!
        load path
        # test_classes = self.test_classes_for(path)
#         return false if test_classes.empty?
#         test_classes.any? do |klass|
#           test_methods = self.test_methods(klass)
#           test_methods.any? do |test_method|
#             test_method =~ /^test\: .*\. $/
#           end
#         end
        !Shoulda.all_contexts.empty?
      ensure
        Shoulda.reset_contexts!
      end

      def tests_for(file)
        Shoulda.reset_contexts!
        load file
        classes = self.class.test_classes_for(file)
        classes.inject([]) do |tests, klass|
          contexts = Shoulda.all_contexts.select { |context| context.parent == klass }
          contexts.each do |context|
            tests += get_tests(file,context)
          end
          build_should_eventually_chains(Shoulda.all_contexts).each do |chain|
            context, description = chain
            tests << [file.to_s, context, description]
          end
          tests
        end
      ensure
        Shoulda.reset_contexts!
      end

      def get_tests(file, context) 
        tests = []
        context.shoulds.each do |should|
          tests << [file.to_s, ancestors(context), should[:name]]
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

      def run(path, contexts, description)
        results = { :passed => [],
          :failed => [],
          :pending => []}
        Shoulda.reset_contexts!
        load(path)
        # Note that this won't work if there are multiple classes in a file
        klass = self.class.test_classes_for(path).first 
        begin
          test = klass.new(test_name([path,contexts,description]))
        rescue NameError
          chains = build_should_eventually_chains(Shoulda.all_contexts)
          if chains.member?([contexts, description])
            results[:pending] << build_result(path, contexts, description)
            return results
          else
            Shoulda.reset_contexts!
            raise NoMatchingTestError, "No matching test found" 
          end
        end
        result = Test::Unit::TestResult.new

        result.add_listener(Test::Unit::TestResult::FAULT) do |failure|
          results[:failed] << build_result(path, contexts, description, failure)
        end
        
        test.run(result) do |started,name|
          # We do nothing here
          # but this method requires a block
        end
        if result.passed?
          results[:passed] << build_result(path, contexts, description) 
        end
        results
      ensure
        Shoulda.reset_contexts!
      end

      private

      def build_should_eventually_chains(contexts)
        chains = []
        # if contexts.length == 1
#           context = contexts.first
#           context.should_eventuallys.each do |should_eventually|
#             chains << [[context.parent.to_s], should_eventually[:name]]
#           end
#         else
        contexts.reject{|context| context.am_subcontext?}.each do |context|
            _build_should_eventually_chains(context, chains)
          end
        #end
        #debugger
        chains
      end

      def _build_should_eventually_chains(context, chains)
        context.should_eventuallys.each do |should_eventually|
          chains << [context_chain(context), should_eventually[:name]]
        end
        context.subcontexts.each do |subcontext|
          _build_should_eventually_chains(subcontext, chains)
        end
        chains
      end
      
      def context_chain(context)
        if context.am_subcontext?
          context_chain(context.parent) + [context.name]
        else
          if context.name + "Test" == context.parent.to_s
            [context.parent.to_s]
          else
            [context.parent.to_s, context.name]
          end
        end
      end

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
      
      def build_result(path, contexts, description, failure=nil)
        { :test => [path.to_s, contexts, description], 
          :failure => build_failure(failure) }
      end

      def build_failure(failure)
        return nil if failure.nil?
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

    end

  end

end
