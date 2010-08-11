require 'test_helper'

class PrintPendingTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    PrintPending
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
