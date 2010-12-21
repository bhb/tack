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

    class ShouldaAdapter < TestUnitAdapter
      
      def self.shoulda_file?(path)
        Shoulda.reset_contexts!
        Tack::SandboxLoader.load(path)
        !Shoulda.all_contexts.empty?
      ensure
        Shoulda.reset_contexts!
      end

      def initialize
        @contexts_cache = {}
        @chains_cache = {}
        @top_level_contexts_cache = {}
        super
      end

      def tests_for(path)
        classes = test_classes_for(path)
        tests = []
        classes.each do |klass|
          tests_for_class = []
          contexts = top_level_contexts_for(path, klass)
          contexts.each do |context|
            tests_for_class += get_tests(path,context)
          end
          should_eventually_chains(path).each do |chain|
            context, description = chain
            tests_for_class << [path.to_s, context, description]
          end
          if tests_for_class.empty?
            tests_for_class << [path.to_s, [klass.to_s], 'default_test']
          end
          tests += tests_for_class
        end
        tests.each do |test|
          _, contexts, _ = test
          contexts.first.sub!(Tack::Sandbox.prefix,'')
          contexts.delete("")
        end
        tests
      end

      def run_test(test)
        path, contexts, description = test
        result = nil
        contexts = contexts.clone
        contexts[0] = Tack::Sandbox.prefix+contexts[0]
        # Note that this won't work if there are multiple classes in a path
        test_classes_for(path).each do |klass|
          next if contexts.first != klass.to_s
          begin
            testcase = klass.new(test_name(contexts, description))
          rescue NameError
            chains = should_eventually_chains(path)
            if chains.member?([contexts, description]) ||
                chains.member?([contexts.map{|x| x.sub(Tack::Sandbox.prefix,'')}, description])
              return basics(build_result(:pending, test))
            else
              Shoulda.reset_contexts!
              raise NoMatchingTestError, Tack::Util::Test.new(path,clean_contexts(contexts),description) 
            end
          end
          result = execute(testcase, test)
        end
        return result
      end

      private

      def discover_contexts(path)
        Shoulda.reset_contexts!
        Tack::SandboxLoader.load(path)
        Shoulda.all_contexts
      ensure
        Shoulda.reset_contexts!
      end

      # TODO - these caches are all very similar. Metaprogramming to the rescue?
      def top_level_contexts_for(path, klass)
        if !@top_level_contexts_cache.has_key?([path,klass])
          @top_level_contexts_cache[[path,klass]] = contexts_for(path).select { |context| context.parent.to_s == klass.to_s }
        end
        @top_level_contexts_cache[[path,klass]]
      end
      
      def contexts_for(path)
        if !@contexts_cache.has_key?(path)
          @contexts_cache[path] = discover_contexts(path)
        end
        @contexts_cache[path]
      end

      def should_eventually_chains(path)
        if !@chains_cache.has_key?(path)
          @chains_cache[path] = build_should_eventually_chains(contexts_for(path))
        end
        @chains_cache[path]
      end

      def get_tests(path, context) 
        tests = []
        context.shoulds.each do |should|
          tests << [path.to_s, ancestors(context), "should "+should[:name]]
        end
        context.subcontexts.each do |subcontext|
          tests += get_tests(path, subcontext)
        end
        tests.sort
      end

      def ancestors(context)
        ancestors = [context.name]
        parent = context
        until ((parent=parent.parent).is_a? Class)
          ancestors.unshift(parent.name)
        end
        # Blindly replacing Test with '' seems insane, but it's real Shoulda behavior
        ancestors.reject! {|context_name| context_name == parent.to_s.gsub('Test','')}
        [parent.to_s] + ancestors
      end
      
      def build_should_eventually_chains(contexts)
        chains = []
        contexts.reject{|context| context.am_subcontext?}.each do |context|
            _build_should_eventually_chains(context, chains)
          end
        chains
      end

      def _build_should_eventually_chains(context, chains)
        context.should_eventuallys.each do |should_eventually|
          chains << [context_chain(context), "should "+should_eventually[:name]]
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

      def test_name(contexts, description)
        return description if description == 'default_test' && contexts.length == 1
        if contexts.length == 1
          class_under_test = contexts.first.gsub(/Test/,'')
          context_description = class_under_test
        else
          context_description = (contexts[1..-1] || []).join(" ")          
        end
        ["test:", context_description, "#{description}. "].join(" ")
      end
      
      def clean_contexts(contexts)
        contexts[0] = contexts[0].gsub(Tack::Sandbox.prefix,'')
        contexts
      end

      def test_classes_for(path)
        @test_classes ||= TestClassDetector.test_classes_for(path) do |test_path|
          Tack::SandboxLoader.load(test_path)
        end
      end

    end

  end

end
