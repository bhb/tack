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
    adapter = Tack::StubAdapter.new
    test = Tack::Util::Test.new('foo.rb',['Foo', 'sometimes'], 'should fail')
    adapter.fail(test, 'fail', [])
    assert_output_matches /Foo sometimes should fail/ do |output|
      middleware = PrintFailures.new(adapter, :output => output)
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
