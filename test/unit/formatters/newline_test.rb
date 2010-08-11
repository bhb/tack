require 'test_helper'

class NewlineTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    Newline
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
