module Tack

  module Formatters

    class Profiler
      include Middleware::Base

      def initialize(app, args={})
        super
        @num_tests = args.fetch(:tests) { 10 }
        @times = []
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          @output.puts "\n\nTop #{@num_tests} slowest tests:\n"
          @times = @times.sort_by do |description, time|
            time
          end.reverse
          @times[0..@num_tests-1].each do |description, time| 
            @output.print "%.7f" % time
            @output.puts " #{description}"
          end
        end
      end

      def run_test(test)
        time = Time.now
        returning @app.run_test(test) do 
          @times << [Tack::Util::Test.new(test).name, Time.now - time]
        end
      end

    end
    
  end

end

