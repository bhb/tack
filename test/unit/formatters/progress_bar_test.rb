require 'test_helper'

class ProgressBarTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    ProgressBar
  end

  should_behave_like_middleware
  should_behave_like_formatter

  should "print P for a pending test" do
    adapter = Tack::StubAdapter.new
    adapter.pend(Test.make)
    output = StringIO.new
    middleware = ProgressBar.new(adapter, :output => output)
    middleware.run_test(*Test.make.to_basics)
    assert_equal 'P', output.string
  end

  should "print . for a passing test" do
    adapter = Tack::StubAdapter.new
    adapter.pass(Test.make)
    output = StringIO.new
    middleware = ProgressBar.new(adapter, :output => output)
    middleware.run_test(*Test.make.to_basics)
    assert_equal '.', output.string
  end

  should "print F for a failing test" do
    adapter = Tack::StubAdapter.new
    adapter.fail(Test.make)
    output = StringIO.new
    middleware = ProgressBar.new(adapter, :output => output)
    middleware.run_test(*Test.make.to_basics)
    assert_equal 'F', output.string
  end

end
