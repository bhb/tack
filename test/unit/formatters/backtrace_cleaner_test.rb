require 'test_helper'

class BacktraceCleanerTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util
  include Tack

  def middleware_class
    BacktraceCleaner
  end

  should_behave_like_middleware
  should_behave_like_formatter
  
  context "by default" do

    should "remove lines contains tack executable" do
      backtrace = ['line1', 'bin/tack:5:', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal %w{line1 line3}, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "remove lines contains tack code" do
      backtrace = ['line1', './lib/tack/middleware/base.rb:17:in `run_test\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal %w{line1 line3}, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "remove lines containing Shoulda code" do
      backtrace = ['line1', 'lib/shoulda/context.rb:382:in `call\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal %w{line1 line3}, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "remove lines containing Test::Unit code" do
      backtrace = ['line1', 'gems/test/unit/testcase.rb:78:in `run\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal %w{line1 line3}, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "remove lines containing RSpec code" do
      backtrace = ['line1', 'lib/spec/runner/example_group_runner.rb', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal %w{line1 line3}, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not alter non-filtered lines" do
      backtrace = ['./foo/bar', './foo/baz']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not remove line for file in local test/unit directory" do
      backtrace = ['line1', './test/unit/foo_test.rb:78:in `run\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not remove line that happens to have shoulda in the file name" do
      backtrace = ['line1', './shoulda_throwaway_test.rb:21', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

  end

  context "when full backtrace is requested" do
    
    should "not remove lines contains tack executable" do
      backtrace = ['line1', 'bin/tack:5:', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not remove lines contains tack code" do
      backtrace = ['line1', './lib/tack/middleware/base.rb:17:in `run_test\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not remove lines containing Shoulda code" do
      backtrace = ['line1', 'lib/shoulda/context.rb:382:in `call\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not remove lines containing Test::Unit code" do
      backtrace = ['line1', 'gems/test/unit/testcase.rb:78:in `run\'', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

    should "not remove lines containing RSpec code" do
      backtrace = ['line1', 'lib/spec/runner/example_group_runner.rb', 'line3']
      adapter = StubAdapter.new(Test.make => [:fail, "fail msg", backtrace])
      middleware = BacktraceCleaner.new(adapter, :full => true)
      assert_equal backtrace, middleware.run_test(Test.make.to_basics)[:failure][:backtrace]
    end

  end

end
