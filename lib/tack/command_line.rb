require 'bleak_house' if ENV['BLEAK_HOUSE']
require 'rubygems' unless ENV['NO_RUBYGEMS']
require 'optparse'
require 'pp'

module Tack

  class CommandLine

    def self.run(args, opts = {})
      stdout = opts.fetch(:stdout) { STDOUT }
      stderr = opts.fetch(:stderr) { STDERR }

      trap("INT") do
        stdout.puts "\n\n Quitting ... \n"
        exit 0  
      end

      command_line_options ||= {}
      
      command_line_options[:pattern] ||= []
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: tack [options] [file]"
        opts.on("-I","--include PATH", "Specify $LOAD_PATH (may be used more than once).") do |path|
          command_line_options[:include] = path.split(":")
        end
        opts.on("-n", "--name PATTERN", "Run only tests that match pattern. Can be used multiple times to run tests that match ANY of the patterns.") do |pattern|
          if pattern=~/^\/.*\/$/
            command_line_options[:pattern] << Regexp.new(pattern[1..-2])
          else
            command_line_options[:pattern] << pattern
          end
        end
        opts.on("-u", "--debugger", "Enable ruby-debugging.") do
          require_ruby_debug
        end
        opts.on("-o", "--profile [NUMBER]", Integer, "Display a text-based progress bar with profiling data on the NUMBER slowest examples (defaults to 10).") do |number|
          command_line_options[:profile_number] = number || 10
        end
        opts.on("-s", "--shuffle", "Run tests in randomized order.") do |runs|
          command_line_options[:shuffle_runs] = true
        end
        opts.on("-R", "--reverse", "Run tests in reverse order.") do 
          command_line_options[:reverse] = true
        end
        opts.on("-F", "--fork", "Run each test in a separate process") do
          command_line_options[:fork] = true
        end
        opts.on('-v', '--verbose', "Display the full test name before running") do
          command_line_options[:verbose] = true
        end
        opts.on('-d', '--dry-run', "Display (but do not run) matching tests") do
          command_line_options[:dry_run] = true
        end
        opts.on('-b', '--backtrace', 'Output full backtrace') do
          command_line_options[:backtrace] = true
        end
        opts.on('-p', '--parallel [NUMBER]', Integer, 'Run tests in NUMBER processes (experimental). Defaults to the number of processors.') do |number|
          command_line_options[:processes] = number
        end
        opts.on('--adapters', "Display the adapters that will be used for each file and quit.") do
          command_line_options[:view_adapters] = true
        end
        opts.on('--middleware', "Display the middleware stack and quit.") do
          command_line_options[:view_middleware] = true
        end
        opts.on('--no-config', "Do not load options from the .tackrc config file") do
          command_line_options[:no_config] = true
        end
        opts.on_tail("-h","--help", "Show this message") do
          stdout.puts opts
          return status = 0
        end
      end

      option_parser.parse! args
      
      options = nil
      if command_line_options[:no_config]
        stdout.puts "Skipping reading .tackrc"
        options = command_line_options
      else
        Tack::ConfigFile.read(stdout)
        options_from_config = Tack.options
        options = options_from_config.merge(command_line_options)
      end

      options[:paths] ||= []
      options[:paths] = args unless args.empty? || args.nil?

      raise OptionParser::MissingArgument, 'No test files provided' if options[:paths].empty?
      if includes = options[:include]
        $LOAD_PATH.unshift *includes
      end

      tests = []
      options[:extra_test_files] ||= []

      missing_files = false
      
      [:paths, :extra_test_files].each do |key|
        options[key] = expand_globs(options[key])
      end

      (options[:paths] + options[:extra_test_files]).each do |path|
        if !File.exists?(path)
          stderr.puts "#{path}: No such file or directory"
          missing_files = true 
        end
      end
      if missing_files
        stderr.puts "Some test files were missing. Quitting."
        return status = 1
      end

      # Test::Unit will find tests in any subsclass of Test::Unit::TestCase, 
      # and sometimes libraries extend it in a helper class. This hidden
      # option (only usable in a .tackrc) will force Tack to load tests from
      # a non-test file.
      (options[:extra_test_files]).each do |file, adapter_klass|
        tests += adapter_klass.new().tests_for(file)
      end
      
      set = Tack::TestSet.new
      tests += set.tests_for(options[:paths], options[:pattern].map{|p|Tack::TestPattern.new(p)})

      runner = Tack::Runner.new(:root => Dir.pwd) do |runner|
        runner.use Tack::Middleware::MiddlewareViewer if options[:view_middleware]
        runner.use Tack::Middleware::DryRun if options[:dry_run]
        runner.use Tack::Middleware::AdapterViewer if options[:view_adapters]
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
        runner.use Tack::Middleware::HandleInterrupt
        runner.use Tack::Formatters::Newline
        runner.use Tack::Formatters::ProgressBar, :verbose => options[:verbose]
        runner.use Tack::Formatters::BacktraceCleaner, :full => options[:backtrace]
        runner.use Tack::Middleware::Parallel, :processes => options[:processes].to_i if options.has_key?(:processes)
      end
      
      runs = 1
      results = {}
      runs.times do |i|
        puts "\n---- Running test run ##{i+1} ----" unless runs == 1
        results.merge!(runner.run(tests))
      end
      
      if (!results.has_key?(:failed) || results[:failed].empty?)
        return status = 0
      else
        return status = 1
      end

    rescue Tack::Adapters::AdapterDetectionError, Tack::NoMatchingTestError => e
      stderr.puts e.message
      return status = 1
    rescue OptionParser::ParseError => e
      stderr.puts e.message
      stderr.puts option_parser
      return status = 1
    end

    def self.require_ruby_debug
      if rbx?
        require 'debugger'
      else
        require 'ruby-debug'
      end
    end

    def self.expand_globs(paths)
      paths.map do |path| 
        paths = Dir.glob(path) 
        if paths.empty?
          path
        else
          paths
        end
      end.flatten
    end

  end


end
