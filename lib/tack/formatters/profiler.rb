module Tack

  module Formatters

    class Profiler
      include Middleware

      def initialize(app)
        @app = app
        @times = []
      end

      def run_suite(tests)
        returning @app.run_suite(tests) do |results|
          puts "\n\nTop 10 slowest examples:\n"
          @times = @times.sort_by do |description, time|
            time
          end.reverse
          @times[0..9].each do |description, time| 
            print "%.7f" % time
            puts " #{description}"
          end
        end
      end

      def run_test(file, description)
        time = Time.now
        returning @app.run_test(file,description) do 
          @times << [description, Time.now - time]
        end
      end

    end
    
  end

end

