require 'test_helper'

class StubAdapter
  include Tack
  
  def initialize(mapping={})
    @mapping = {}
    mapping.each do |key, value|
      @mapping[basics(key)] = value
    end
  end

  def run_test(path,contexts,description)
    test = [path,contexts,description]
    result = @mapping[test]
    raise "No stubbed result for #{test.inspect}" if result.nil?
    status, message, backtrace = result
    case status
    when :fail
      ResultSet.new(:failed => [Result.new(:test => test, 
                                          :failure => { :message => message, 
                                            :backtrace => backtrace})]).to_basics
    else
      raise "Unknown status #{status}"
    end
  end

end

class BacktraceCleanerTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

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
    
    should "not remove lines contains tack executable" do
      backtrace = ['line1', 'bin/tack:5:', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      # TODO - Yeah, it's pretty awful to pull this stuff out
      assert_equal backtrace, middleware.run_test(*Test.make.to_basics)[:failed].first[:failure][:backtrace]
    end

    should "not remove lines contains tack code" do
      backtrace = ['line1', './lib/tack/middleware/base.rb:17:in `run_test\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(*Test.make.to_basics)[:failed].first[:failure][:backtrace]
    end

    should_eventually "not remove lines containing Shoulda code" do
    end

    should "not remove lines containing Test::Unit code" do
      backtrace = ['line1', 'test/unit/testcase.rb:78:in `run\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(*Test.make.to_basics)[:failed].first[:failure][:backtrace]
    end

    should_eventually "not remove lines containing RSpec code" do
    end

  end

end
