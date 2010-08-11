require 'test_helper'

class ProgressBarTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    ProgressBar
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
