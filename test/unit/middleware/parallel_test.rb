require 'test_helper'

class ParallelTest < Test::Unit::TestCase
  include MiddlewareTestHelper
  include Tack::Middleware

  def middleware_class
    Parallel
  end

  should_implement_middleware_api
  should_not_modify_results
  
end
