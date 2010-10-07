require 'test_helper'

class NewlineTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    Newline
  end

  should_behave_like_middleware
  should_behave_like_formatter

  should "output one newline by default" do
    adapter = Tack::StubAdapter.new(Test.make => :pass)
    output = StringIO.new
    middleware = Newline.new(adapter, :output => output)
    middleware.run_suite([Test.make])
    assert_match "\n", output.string
  end

  should "output several newlines" do
    adapter = Tack::StubAdapter.new(Test.make => :pass)
    output = StringIO.new
    middleware = Newline.new(adapter, :output => output, :times => 3)
    middleware.run_suite([Test.make])
    assert_match "\n\n\n", output.string
  end

end
