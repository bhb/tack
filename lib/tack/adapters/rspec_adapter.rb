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
        
        attr_accessor :result
        attr_accessor :file
        
        def initialize
          # suppress output
          io = StringIO.new 
          super(io)
        end

        def example_pending(example)
          @result = build_result(:pending, example)
        end

        def example_passed(example)
          @result = build_result(:passed, example)
        end

        def example_failed(example)
          error = example.execution_result[:exception_encountered] || example.execution_result[:exception]
          @result = build_result(:failed, example, error)
        end

        def example_group_started(example_group_proxy)
          @current_example_group = example_group_proxy
        end

        private

        def build_result(status, example, error = nil)
          { :status => status,
            :test => [example.file_path, @current_example_group.ancestors.reverse.map{|x|x.description}, example.description],
            :failure => build_failure(error) }
        end
        
        def build_failure(error)
          return nil if error.nil?
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

      def initialize
        @configuration_cache = Hash.new
        @example_groups_cache = Hash.new
        super
      end
      
      def tests_for(file)
        world = RSpec.world
        world.example_groups.clear
        configuration = RSpec.configuration
        configuration.files_to_run = [file]
        configuration.load_spec_files
        configuration.configure_mock_framework

        example_groups = world.example_groups.map{|x| x.descendants}.flatten
        
        examples = []
        example_groups.each do |example_group|
          examples += example_group.examples.map { |example| [example_group, example]}
        end
        examples.map {|group, example| 
          [file.to_s, group.ancestors.reverse.map{|x|x.description}, example.description]
        }
      end
      
      def run_test(test)
        path, contexts, description = test
        world = RSpec.world
        world.example_groups.clear
        world.filtered_examples.clear
        
        configuration = configuration_for(path)
        world.example_groups.replace(example_groups_for(path, world.example_groups))
        configuration.clear_inclusion_filter
        configuration.filter_run :full_description => full_example_name(contexts,description)

        formatter = RSpec::Core::Formatters::TackFormatter.new
        reporter = RSpec::Core::Reporter.new(formatter)
        world.example_groups.each do |g| 
          g.run(reporter)
        end
        result = formatter.result
        if result.nil?
          raise NoMatchingTestError, Tack::Util::Test.new(test)
        end
        result[:test] = test
        basics(result)
      end

      private

      def configuration_for(path)
        if !@configuration_cache.has_key?(path)
          configuration = RSpec.configuration
          configuration.files_to_run = [path]
          configuration.load_spec_files
          configuration.configure_mock_framework
          @configuration_cache[path] = configuration
        end
        @configuration_cache[path]
      end
      
      def example_groups_for(path, example_groups)
        if !@example_groups_cache.has_key?(path)
          @example_groups_cache[path] = example_groups.clone
        end
        @example_groups_cache[path]
      end

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
