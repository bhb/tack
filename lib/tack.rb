libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'tack/test_set'
require 'tack/runner'
require 'tack/adapters/adapter'
require 'tack/adapters/rspec_adapter'
require 'tack/adapters/test_unit_adapter'

module Tack
end
