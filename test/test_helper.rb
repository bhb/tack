require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'construct'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tack'

class Test::Unit::TestCase
  include Construct::Helpers
end
