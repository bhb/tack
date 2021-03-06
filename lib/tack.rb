libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'tack/basics'
require 'tack/ext/kernel'

module Tack

  autoload :ConfigFile, 'tack/config_file'
  autoload :CommandLine, 'tack/command_line'
  autoload :NoMatchingTestError, 'tack/no_matching_test_error'
  autoload :Runner, 'tack/runner'
  autoload :TestPattern, 'tack/test_pattern'
  autoload :TestSet, 'tack/test_set'
  autoload :Sandbox, 'tack/sandbox'
  autoload :SandboxLoader, 'tack/sandbox'
  autoload :ForkedSandbox, 'tack/forked_sandbox'
  autoload :StableSort, 'tack/stable_sort'

  module Util
    autoload :Result, 'tack/util/result'
    autoload :ResultSet, 'tack/util/result_set'
    autoload :Test, 'tack/util/test'
    autoload :TestFailure, 'tack/util/test_failure'
  end
  
  module Middleware

    autoload :AdapterViewer, 'tack/middleware/adapter_viewer'
    autoload :Base, 'tack/middleware/base'
    autoload :DryRun, 'tack/middleware/dry_run'
    autoload :Fork, 'tack/middleware/fork'
    autoload :HandleInterrupt, 'tack/middleware/handle_interrupt'
    autoload :MiddlewareViewer, 'tack/middleware/middleware_viewer'
    autoload :Parallel, 'tack/middleware/parallel'
    autoload :Reverse, 'tack/middleware/reverse'
    autoload :Shuffle, 'tack/middleware/shuffle'

    
  end

  module Adapters

    autoload :Adapter, 'tack/adapters/adapter'
    autoload :AdapterDetectionError, 'tack/adapters/adapter'
    autoload :RSpecAdapter, 'tack/adapters/rspec_adapter'
    autoload :ShouldaAdapter, 'tack/adapters/shoulda_adapter'
    autoload :TestUnitAdapter, 'tack/adapters/test_unit_adapter'
    autoload :TestClassDetector, 'tack/adapters/test_class_detector'

  end
  
  module Formatters
    
    autoload :BacktraceCleaner, 'tack/formatters/backtrace_cleaner'
    # TODO - Should make a 'helpers' directory within Formatters
    autoload :QuietBacktrace, 'tack/formatters/quiet_backtrace'
    autoload :BasicSummary, 'tack/formatters/basic_summary'
    autoload :Newline, 'tack/formatters/newline'
    autoload :PrintFailures, 'tack/formatters/print_failures'
    autoload :PrintPending, 'tack/formatters/print_pending'
    autoload :Profiler, 'tack/formatters/profiler'
    autoload :ProgressBar, 'tack/formatters/progress_bar'
    autoload :TotalTime, 'tack/formatters/total_time'

  end

end
