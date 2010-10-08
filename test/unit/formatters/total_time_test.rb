require 'test_helper'

class TotalTimeTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    TotalTime
  end

  should_behave_like_middleware
  should_behave_like_formatter

  should "print total time" do
    adapter = StubAdapter.new
    adapter.pass(Test.make)
    output = StringIO.new
    middleware = TotalTime.new(adapter, :output => output)
    middleware.run_suite([Test.make])
    assert_match /Finished in \d+.\d+ seconds/, output.string
  end

end
