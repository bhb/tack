libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

module Tack

  autoload :Runner, 'tack/runner'
  autoload :TestSet, 'tack/test_set'
  autoload :Middleware, 'tack/middleware'
  autoload :TestPattern, 'tack/test_pattern'
  autoload :NoMatchingTestError, 'tack/no_matching_test_error'

  # convenience objects
  autoload :ResultSet, 'tack/result_set'
  autoload :Result, 'tack/result'
  #autoload :Test, 'tack/test'
  
  # middlewares

  autoload :Shuffle, 'tack/shuffle'
  autoload :Reverse, 'tack/reverse'

  module Adapters

    autoload :Adapter, 'tack/adapters/adapter'
    autoload :RSpecAdapter, 'tack/adapters/rspec_adapter'
    autoload :TestUnitAdapter, 'tack/adapters/test_unit_adapter'
    autoload :ShouldaAdapter, 'tack/adapters/shoulda_adapter'

  end
  
  module Formatters
    
    autoload :BasicSummary, 'tack/formatters/basic_summary'
    autoload :ProgressBar, 'tack/formatters/progress_bar'
    autoload :Profiler, 'tack/formatters/profiler'
    autoload :TotalTime, 'tack/formatters/total_time'
    autoload :PrintFailures, 'tack/formatters/print_failures'
    autoload :PrintPending, 'tack/formatters/print_pending'

  end

end
