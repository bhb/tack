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
    adapter = Tack::StubAdapter.new
    adapter.pass(Test.make)
    assert_output_matches /Finished in \d+.\d+ seconds/ do |output|
      middleware = TotalTime.new(adapter, :output => output)
      middleware.run_suite([Test.make.to_basics])
    end
  end

end
