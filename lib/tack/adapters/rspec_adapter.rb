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
        
        def initialize(options)
          io = StringIO.new # suppress output
          super(options, io)
          @results = { :passed => [],
            :failed => [],
            :pending => []}
        end

        # Stifle the output of pending examples
        def example_pending(example)
          @results[:pending] << {
            :description => example.description,
          }
        end

        def example_passed(example)
          @results[:passed] << {
            :description => example.description,
          }
        end

        def example_failed(example, counter, error=nil)
          @results[:failed] <<
            {
            :description => example.description,
            :failure => build_failure(example, error)
          }
        end

        private
        
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

    class RSpecAdapter

      def tests_for(file)
        Spec::Runner.options.instance_variable_set(:@formatters, [Spec::Runner::Formatter::TackFormatter.new(Spec::Runner.options.formatter_options)])
        Spec::Runner.options.instance_variable_set(:@example_groups, [])
        Spec::Runner.options.instance_variable_set(:@files, [file])
        Spec::Runner.options.instance_variable_set(:@files_loaded, false)
        runner = Spec::Runner::ExampleGroupRunner.new(Spec::Runner.options)
        runner.load_files([file])
        example_groups = runner.send(:example_groups)
        examples = example_groups.inject([]) do |arr, group|
          arr += group.examples
        end
        examples.map {|example| [file, example.description]}
      end
      
      def run(file, test)
        Spec::Runner.options.instance_variable_set(:@examples, [test])
        Spec::Runner.options.instance_variable_set(:@example_groups, [])
        Spec::Runner.options.instance_variable_set(:@files, [file])
        Spec::Runner.options.instance_variable_set(:@files_loaded, false)
        formatter = Spec::Runner::Formatter::TackFormatter.new(Spec::Runner.options.formatter_options)
        Spec::Runner.options.instance_variable_set(:@formatters, [formatter])
        Spec::Runner.options.run_examples
        formatter.results
      end

    end

  end
end
