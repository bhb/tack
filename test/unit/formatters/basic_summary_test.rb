require 'test_helper'

class BasicSummaryTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    BasicSummary
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
