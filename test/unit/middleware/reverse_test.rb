require 'test_helper'

class ReverseTest < Test::Unit::TestCase
  include MiddlewareTestHelper

  def middleware_class
    Tack::Middleware::Reverse
  end

  should_behave_like_middleware

end
