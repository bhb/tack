module Tack

  module Formatters

    class Profiler

      def initialize(app)
        @app = app
        @times = []
      end

      def run_suite(tests)
        results = @app.run_suite(tests)
        puts "\n\nTop 10 slowest examples:\n"
        @times = @times.sort_by do |description, time|
          time
        end.reverse
        @times[0..9].each do |description, time| 
          print "%.7f" % time
          puts " #{description}"
        end
        results
      end

      def run_test(file, description)
        time = Time.now
        result = @app.run_test(file,description)
        @times << [description, Time.now - time]
        result
      end

    end
    
  end

end

