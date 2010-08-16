require 'test_helper'

class ReverseTest < Test::Unit::TestCase
  include MiddlewareTestHelper
  include Tack::Middleware

  def middleware_class
    Reverse
  end

  should_behave_like_middleware

end
