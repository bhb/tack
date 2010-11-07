# Only works with RSpec >= 2.0.0
require 'rspec'
require 'rspec/core/formatters/base_formatter'

if defined?(RSpec)
  RSpec::Core::Runner.disable_autorun!
end

module RSpec
  module Core
    module Formatters

      class TackFormatter < BaseFormatter
        
        attr_accessor :results
        attr_accessor :file
        
        def initialize
          # suppress output
          io = StringIO.new 
          super(io)
          @results = Tack::ResultSet.new
        end

        def example_pending(example)
          @results.pending << {
            :test => build_result(example)
          }
        end

        def example_passed(example)
          @results.passed << {
            :test => build_result(example)
          }
        end

        def example_failed(example)
          error = example.execution_result[:exception_encountered]
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
          [example.file_path, @current_example_group.ancestors.reverse.map{|x|x.description}, example.description]
        end
        
        def build_failure(example, error)
          case error.exception
          when RSpec::Expectations::ExpectationNotMetError
            Tack::Util::TestFailure.new(error.exception.message,error.exception.backtrace).to_basics
          else
            Tack::Util::TestFailure.new("#{error.exception.class} was raised: #{error.exception.message}",error.exception.backtrace).to_basics
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
        world = RSpec.world
        world.example_groups.clear
        configuration = RSpec.configuration
        configuration.files_to_run = [file]
        configuration.load_spec_files
        configuration.configure_mock_framework

        example_groups = world.example_groups.map{|x| x.descendants}.flatten
        
        examples = example_groups.inject([]) do |arr, group|
          arr += group.examples.map { |example| [group, example]}
        end
        examples.map {|group, example| 
          [file.to_s, group.ancestors.reverse.map{|x|x.description}, example.description]
        }
      end
      
      def run_test(file, contexts, description)
        world = RSpec.world
        world.example_groups.clear
        configuration = RSpec.configuration
        configuration.clear_inclusion_filter
        configuration.files_to_run = [file]
        configuration.load_spec_files
        configuration.configure_mock_framework
        configuration.filter_run :full_description => full_example_name(contexts,description)

        formatter = RSpec::Core::Formatters::TackFormatter.new
        reporter = RSpec::Core::Reporter.new(formatter)
        world.example_groups.map {|g| g.run(reporter)}
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
