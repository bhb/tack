require 'test_helper'

class BasicSummaryTest < Test::Unit::TestCase
  include Tack::Formatters
  include TestHelpers
  extend FormatterTestHelper

  should_behave_like_formatter

  def middleware_class
    BasicSummary
  end

end
