require 'test_helper'

class TotalTimeTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    TotalTime
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
