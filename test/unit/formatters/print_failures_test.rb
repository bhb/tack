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
    # TODO look for instances of stub_everything and use stub_adapter
    fake_middleware = stub_everything
    assert_output_matches /Foo sometimes should fail/ do |output|
      middleware = PrintFailures.new(fake_middleware, :output => output)
      test = Tack::Util::Test.new('foo.rb',['Foo', 'sometimes'], 'should fail')
      results = Tack::ResultSet.new()
      results.fail(test, Tack::Util::TestFailure.make)
      # TODO - find all instances of stubs(:run_suite and fix!)
      fake_middleware.stubs(:run_suite).returns(results.to_basics)
      middleware.run_suite([test])
    end
  end

  should "print backtrace" do
    adapter = Tack::StubAdapter.new
    backtrace = ['line1', 'line2']
    adapter.fail(Test.make, "fail!", backtrace)
    assert_output_matches /line1\nline2/ do |output|
      middleware = PrintFailures.new(adapter, :output => output)
      middleware.run_suite([Test.make])
    end
  end

end
