require 'test_helper'

class ProfilerTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    Profiler
  end

  should_behave_like_middleware
  should_behave_like_formatter

end
