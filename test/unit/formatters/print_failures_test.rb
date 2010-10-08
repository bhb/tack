require 'test_helper'

class PrintFailuresTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    PrintFailures
  end

  should_behave_like_middleware
  should_behave_like_formatter
  
  should "print name of test" do
    fake_middleware = stub_everything
    output = StringIO.new
    middleware = PrintFailures.new(fake_middleware, :output => output)
    test = Tack::Util::Test.new('foo.rb',['Foo', 'sometimes'], 'should fail')
    results = Tack::ResultSet.new()
    results.fail(test, Tack::Util::TestFailure.make)
    # TODO - find all instances of stubs(:run_suite and fix!)
    fake_middleware.stubs(:run_suite).returns(results.to_basics)
    middleware.run_suite([test])
    assert_match /Foo sometimes should fail/, output.string
  end

  should "print backtrace" do
    adapter = Tack::StubAdapter.new
    backtrace = ['line1', 'line2']
    adapter.fail(Test.make, "fail!", backtrace)
    output = StringIO.new
    middleware = PrintFailures.new(adapter, :output => output)
    middleware.run_suite([Test.make])
    assert_match /line1/, output.string
    assert_match /line2/, output.string
  end

end
