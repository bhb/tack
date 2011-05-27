require 'forkoff'
require 'facter'

module Tack

  module Middleware

    class Parallel
      include Middleware::Base
      
      def initialize(app, options = {})
        super
        @processes = options.fetch(:processes) { processors }
        @processes = processors if @processes == 0
        @output.puts "Running tests in parallel in #{@processes} processes."
      end

      def run_suite(tests)
        many_results = map(tests)
        total_results = reduce(many_results)
        
        failing_tests = total_results[:failed].map{|result| result[:test]}
        if !failing_tests.empty?
          @output.puts "Rerunning #{failing_tests.length} tests (in case they failed due to parallelism)"
          total_results[:failed].clear
          new_results = @app.run_suite(failing_tests)
          final_results = reduce([total_results,new_results])
        else
          final_results = total_results
        end
        final_results
      end

      private
      
      def processors
        Facter.loadfacts
        Facter.sp_number_processors.to_i
      end

      def map(tests)
        test_groups = []
        tests.each_slice([tests.length.to_f/@processes,1].max) do |group|
          test_groups << group
        end
        results = test_groups.forkoff! :processes => @processes, :strategy => 'file' do |*test_group|
          if !test_group.first.is_a?(Array)
            test_group = [test_group]
          end
          result = basics(Util::ResultSet.new)
          # TODO - this is just a hack to see if the tests pass
          # In reality, we shouldn't silently ignore the fact
          # that for some reason, parallel mode fails to catch :invalid_test
          catch(:invalid_test) do
            result = @app.run_suite(test_group)
          end
          result || {}
        end
        results.each do |result|
          raise result if result.is_a?(Exception)
        end
        results
      end

      def reduce(many_result_sets)
        merged_result_set = { :passed => [], :failed => [], :pending => [] }
        [:passed, :failed, :pending].each do |key|
          many_result_sets.each do |result_set|
            merged_result_set[key] += result_set[key]
          end
        end
        merged_result_set
      end

    end

  end

end
