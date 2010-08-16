require 'test_helper'

class ShuffleTest < Test::Unit::TestCase
  include MiddlewareTestHelper
  include Tack::Middleware

  def middleware_class
    Shuffle
  end

  should_behave_like_middleware

end
