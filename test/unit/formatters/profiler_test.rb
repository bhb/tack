require 'test_helper'

class ProfilerTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    Profiler
  end

  should_behave_like_middleware
  should_behave_like_formatter
  
  should "print header" do
    adapter = StubAdapter.new
    test = Test.make
    adapter.pass(test)
    output = StringIO.new
    middleware = Profiler.new(adapter, :output => output)
    middleware.run_suite([test])
    assert_match /Top 10 slowest tests/, output.string
  end
  
  should "print timing information on a specific test" do
    adapter = StubAdapter.new
    test = Test.make
    adapter.pass(test)
    output = StringIO.new
    middleware = Profiler.new(adapter, :output => output)
    adapter.top = middleware
    middleware.run_suite([test])
    assert_match /\d\.\d+ #{test.name}/, output.string
  end

end
