require 'forkoff'

module Tack

  module Middleware

    class Parallel
      include Middleware::Base
      
      def initialize(app, options = {})
        @processes = options.fetch(:processes) { 2 }
        super
      end

      def run_suite(tests)
        many_results = map(tests)
        total_results = reduce(many_results)
        total_results
      end

      private

      def map(tests)
        tests.forkoff! :processes => @processes do |*test|
          @app.run_suite([test])
        end
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
