require 'spec'
require 'spec/runner/formatter/base_formatter'

if defined?(Spec)
  module Spec
    module Runner
      class << self
        # stop the auto-run at_exit
        def run
          return 0
        end 
      end
    end
  end
end

module Spec
  module Runner
    module Formatter
      # Stolen from Hydra for now
      class TackFormatter < BaseFormatter
        
        attr_accessor :results
        attr_accessor :file
        
        def initialize(options)
          io = StringIO.new # suppress output
          super(options, io)
          @results = Tack::ResultSet.new
        end

        def example_pending(example, message, deprecated_pending_location=nil)
          @results.pending << {
            :test => build_result(example)
          }
        end

        def example_passed(example)
          @results.passed << {
            :test => build_result(example)
          }
        end

        def example_failed(example, counter, error=nil)
          @results.failed <<
            {
            :test => build_result(example),
            :failure => build_failure(example, error)
          }
        end

        def example_group_started(example_group_proxy)
          @current_example_group = example_group_proxy
        end

        private

        def build_result(example)
          [@file, @current_example_group.nested_descriptions, example.description]
        end
        
        def build_failure(example, error)
          case error.exception
          when Spec::Expectations::ExpectationNotMetError
            { :message => error.exception.message,
              :backtrace => error.exception.backtrace}
          else
            { :message => "#{error.exception.class} was raised: #{error.exception.message}",
              :backtrace => error.exception.backtrace}
          end
        end

      end
    end
  end
end

module Tack

  module Adapters

    class RSpecAdapter < Adapter

      def tests_for(file)
        Spec::Runner.options.instance_variable_set(:@formatters, [Spec::Runner::Formatter::TackFormatter.new(Spec::Runner.options.formatter_options)])
        Spec::Runner.options.instance_variable_set(:@example_groups, [])
        Spec::Runner.options.instance_variable_set(:@files, [file])
        Spec::Runner.options.instance_variable_set(:@files_loaded, false)
        runner = Spec::Runner::ExampleGroupRunner.new(Spec::Runner.options)
        runner.load_files([file])
        example_groups = runner.send(:example_groups)
        examples = example_groups.inject([]) do |arr, group|
          arr += group.examples.map { |example| [group, example]}
        end
        examples.map {|group, example| [file.to_s, group.description_parts.map {|part| part.to_s}, example.description]}
      end
      
      def run(file, contexts, description)
        Spec::Runner.options.instance_variable_set(:@examples, [full_example_name(contexts, description)])
        Spec::Runner.options.instance_variable_set(:@example_groups, [])
        Spec::Runner.options.instance_variable_set(:@files, [file])
        Spec::Runner.options.instance_variable_set(:@files_loaded, false)
        formatter = Spec::Runner::Formatter::TackFormatter.new(Spec::Runner.options.formatter_options)
        formatter.file = file
        Spec::Runner.options.instance_variable_set(:@formatters, [formatter])
        Spec::Runner.options.run_examples
        results = formatter.results
        
        if results.length == 0
          raise NoMatchingTestError, Tack::Util::Test.new(file,contexts,description)
        end
        basics(results)
      end

      private

      def full_example_name(contexts, description)
        name = contexts.first
        contexts[1..-1].each do |context|
          if !(context=~/^(\s)|\.|#/)
           name += " " 
          end
          name += context
        end
        "#{name} #{description}"
      end

    end

  end
end
