libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

module Tack

  autoload :CommandLine, 'tack/command_line'
  autoload :NoMatchingTestError, 'tack/no_matching_test_error'
  autoload :Runner, 'tack/runner'
  autoload :TestPattern, 'tack/test_pattern'
  autoload :TestSet, 'tack/test_set'

  # convenience objects
  autoload :Result, 'tack/result'
  autoload :ResultSet, 'tack/result_set'
  #autoload :Test, 'tack/test'
  
  module Middleware

    autoload :Base, 'tack/middleware/base'
    autoload :Fork, 'tack/middleware/fork'
    autoload :Reverse, 'tack/middleware/reverse'
    autoload :Shuffle, 'tack/middleware/shuffle'
    
  end

  module Adapters

    autoload :Adapter, 'tack/adapters/adapter'
    autoload :RSpecAdapter, 'tack/adapters/rspec_adapter'
    autoload :ShouldaAdapter, 'tack/adapters/shoulda_adapter'
    autoload :TestUnitAdapter, 'tack/adapters/test_unit_adapter'

  end
  
  module Formatters
    
    autoload :BasicSummary, 'tack/formatters/basic_summary'
    autoload :Newline, 'tack/formatters/newline'
    autoload :PrintFailures, 'tack/formatters/print_failures'
    autoload :PrintPending, 'tack/formatters/print_pending'
    autoload :Profiler, 'tack/formatters/profiler'
    autoload :ProgressBar, 'tack/formatters/progress_bar'
    autoload :TotalTime, 'tack/formatters/total_time'

  end

end
