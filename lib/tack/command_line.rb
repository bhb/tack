require 'optparse'
require 'pp'

module Tack

  class CommandLine

    def self.run(args)
      
      Tack::ConfigFile.read
      options = Tack.options
      options ||= {}
      
      options[:pattern] ||= []
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: tack [options] [file]"
        opts.on("-I","--include PATH", "Specify $LOAD_PATH (may be used more than once).") do |path|
          options[:include] = path.split(":")
        end
        opts.on("-n", "--name PATTERN", "Run only tests that match pattern. Can be used multiple times to run tests that match ANY of the patterns.") do |pattern|
          if pattern=~/^\/.*\/$/
            options[:pattern] << Regexp.new(pattern[1..-2])
          else
            options[:pattern] << pattern
          end
        end
        opts.on("-u", "--debugger", "Enable ruby-debugging.") do
          require_ruby_debug
        end
        opts.on("-o", "--profile [NUMBER]", "Display a text-based progress bar with profiling data on the NUMBER slowest examples (defaults to 10).") do |number|
          options[:profile_number] = number || 10
        end
        opts.on("-s", "--shuffle", "Run tests in randomized order.") do |runs|
          options[:shuffle_runs] = true
        end
        opts.on("-R", "--reverse", "Run tests in reverse order.") do 
          options[:reverse] = true
        end
        opts.on("-F", "--fork", "Run each test in a separate process") do
          options[:fork] = true
        end
        opts.on('-d', '--dry-run', "Display (but do not run) matching tests") do
          options[:dry_run] = true
        end
        opts.on_tail("-h","--help", "Show this message") do
          puts opts
          exit
        end
      end

      option_parser.parse! args
      options[:paths] ||= []
      options[:paths] = args unless args.empty? || args.nil?

      raise OptionParser::MissingArgument, 'No test files provided' if options[:paths].empty?

      if includes = options[:include]
        $LOAD_PATH.unshift *includes
      end

      set = Tack::TestSet.new
      tests = set.tests_for(options[:paths], options[:pattern].map{|p|Tack::TestPattern.new(p)})

      if options[:dry_run]==true
        pp tests
        exit 0
      else
        runner = Tack::Runner.new(:root => Dir.pwd) do |runner|
          runner.use Tack::Middleware::Reverse if options[:reverse]
          runner.use Tack::Middleware::Shuffle if options[:shuffle_runs]
          runner.use Tack::Formatters::Profiler, :tests => options[:profile_number].to_i if options[:profile_number]
          runner.use Tack::Middleware::Fork if options[:fork]
          runner.use Tack::Formatters::BasicSummary
          runner.use Tack::Formatters::Newline
          runner.use Tack::Formatters::PrintFailures
          runner.use Tack::Formatters::Newline
          runner.use Tack::Formatters::TotalTime
          runner.use Tack::Formatters::Newline
          runner.use Tack::Formatters::PrintPending
          runner.use Tack::Formatters::Newline
          runner.use Tack::Formatters::ProgressBar
        end
        
        runs = 1
        results = {}
        runs.times do |i|
          puts "\n---- Running test run ##{i+1} ----" unless runs == 1
          results.merge!(runner.run(tests))
        end
        
        if results[:failed].empty?
          0
        else
          1
        end
      end

    rescue OptionParser::ParseError => e
      puts e.message
      puts option_parser
      exit 1
    end

    def self.require_ruby_debug
      require 'rubygems' unless ENV['NO_RUBYGEMS']
      require 'ruby-debug'
    end

  end


end
