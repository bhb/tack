require 'test_helper'

class BasicSummaryTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    BasicSummary
  end

  should_behave_like_middleware
  should_behave_like_formatter

  should "display total tests, failures, and pending" do
    test1 = ['foo.rb', ['Foo'], 'test_one']
    test2 = ['foo.rb', ['Foo'], 'test_two']
    test3 = ['foo.rb', ['Foo'], 'test_three']
    test4 = ['foo.rb', ['Foo'], 'test_four']
    adapter = Tack::StubAdapter.new do |a|
      a.pass(test1)
      a.fail(test2)
      a.fail(test3)
      a.pend(test4)
    end
    output = StringIO.new
    middleware = BasicSummary.new(adapter, :output => output)
    middleware.run_suite([test1,test2,test3,test4])
    assert_match /4 tests, 2 failures, 1 pending/, output.string
  end

end
