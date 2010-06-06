libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'tack/test_set'
require 'tack/runner'
require 'tack/adapters/adapter'
require 'tack/test_pattern'

module Tack

  module Adapters

    autoload :RSpecAdapter, 'tack/adapters/rspec_adapter'
    autoload :TestUnitAdapter, 'tack/adapters/test_unit_adapter'

  end
  
  module Formatters

    autoload :BasicSummary, 'tack/formatters/basic_summary'

  end

end
