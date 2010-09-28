require 'test_helper'

class PrintFailuresTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

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
    fake_middleware.stubs(:run_suite).returns(results.to_basics)
    middleware.run_suite([test])
    assert_match /Foo sometimes should fail/, output.string
  end

end
