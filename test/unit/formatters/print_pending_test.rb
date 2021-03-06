require 'test_helper'

class PrintPendingTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    PrintPending
  end

  should_behave_like_middleware
  should_behave_like_formatter

  should "print the pending test name" do
    adapter = Tack::StubAdapter.new
    test = Test.make
    adapter.pend(test)
    assert_output_equals "PENDING: #{test.name}\n" do |output|
      middleware = PrintPending.new(adapter, :output => output)
      middleware.run_suite([test])
    end
  end

end
