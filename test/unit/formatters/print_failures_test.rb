require 'test_helper'

class PrintFailuresTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    PrintFailures
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
