libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'tack/test_set'
require 'tack/runner'
require 'tack/adapters/adapter'
require 'tack/test_pattern'

module Tack

  #autoload :Runner, 'tack/runner'
  #autoload :TestSet, 'tack/test_set'
  autoload :Middleware, 'tack/middleware'
  #autoload :TestPattern, 'tack/test_pattern'
  

  module Adapters

    #autoload :Adapter, 'tack/adapters/adapter'
    autoload :RSpecAdapter, 'tack/adapters/rspec_adapter'
    autoload :TestUnitAdapter, 'tack/adapters/test_unit_adapter'

  end
  
  module Formatters
    
    autoload :BasicSummary, 'tack/formatters/basic_summary'
    autoload :ProgressBar, 'tack/formatters/progress_bar'

  end

end
