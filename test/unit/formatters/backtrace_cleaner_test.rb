require 'test_helper'

class BacktraceCleanerTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper

  def middleware_class
    BacktraceCleaner
  end

  should_behave_like_middleware
  should_behave_like_formatter
  
  context "by default" do

    should_eventually "remove lines contains tack executable" do
    end

    should_eventually "remove lines contains tack code" do
    end

    should_eventually "remove lines containing Should_Eventuallya code" do
    end

    should_eventually "remove lines containing Test::Unit code" do
    end

    should_eventually "remove lines containing RSpec code" do
    end

  end

  context "when full backtrace is requested" do
    
    should_eventually "not remove lines contains tack executable" do
    end

    should_eventually "not remove lines contains tack code" do
    end

    should_eventually "not remove lines containing Should_Eventuallya code" do
    end

    should_eventually "not remove lines containing Test::Unit code" do
    end

    should_eventually "not remove lines containing RSpec code" do
    end

  end

end
