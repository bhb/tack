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
    adapter = Tack::StubAdapter.new
    test = Test.make
    adapter.pass(test)
    assert_output_matches /Top 10 slowest tests/ do |output|
      middleware = Profiler.new(adapter, :output => output)
      middleware.run_suite([test])
    end
  end
  
  should "print timing information on a specific test" do
    adapter = Tack::StubAdapter.new
    test = Test.make
    adapter.pass(test)
    assert_output_matches /\d\.\d+ seconds - #{test.name}/ do |output|
      middleware = Profiler.new(adapter, :output => output)
      middleware.run_suite([test])
    end
  end

end
