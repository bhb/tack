require 'test_helper'

class ShuffleTest < Test::Unit::TestCase
  include MiddlewareTestHelper

  def middleware_class
    Tack::Middleware::Shuffle
  end

  should_behave_like_middleware

end
