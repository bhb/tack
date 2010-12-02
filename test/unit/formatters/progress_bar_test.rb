require 'test_helper'

class ProgressBarTest < Test::Unit::TestCase
  include FormatterTestHelper
  include MiddlewareTestHelper
  include Tack::Util

  def middleware_class
    ProgressBar
  end

  should_behave_like_middleware
  should_behave_like_formatter

  should "print P for a pending test" do
    adapter = Tack::StubAdapter.new
    adapter.pend(Test.make)
    assert_output_equals 'P' do |output|
      middleware = ProgressBar.new(adapter, :output => output)
      middleware.run_test(Test.make.to_basics)
    end
  end

  should "print . for a passing test" do
    adapter = Tack::StubAdapter.new
    adapter.pass(Test.make)
    assert_output_equals '.' do |output|
      middleware = ProgressBar.new(adapter, :output => output)
      middleware.run_test(Test.make.to_basics)
    end
  end

  should "print F for a failing test" do
    adapter = Tack::StubAdapter.new
    adapter.fail(Test.make)
    assert_output_equals 'F' do |output|
      middleware = ProgressBar.new(adapter, :output => output)
      middleware.run_test(Test.make.to_basics)
    end
  end

  should "not change output sync" do
    adapter = Tack::StubAdapter.new
    adapter.pass(Test.make)

    StubIO = Struct.new(:sync) do
      def closed?; false; end;
      def print(*args); end;
    end

    output = StubIO.new

    [true, false].each do |value|
      output.sync = value
      assert_equal value, output.sync
      middleware = ProgressBar.new(adapter, :output => output)
      middleware.run_test(Test.make.to_basics)
      assert_equal value, output.sync
    end
  end

  context "in verbose mode" do

    should "print P for a pending test" do
      adapter = Tack::StubAdapter.new
      test = Test.new('file.rb', ['Foo'], 'should do x')
      adapter.pend(test)
      assert_output_equals "Foo should do x: P\n" do |output|
        middleware = ProgressBar.new(adapter, :verbose => true, :output => output)
        middleware.run_test(test.to_basics)
      end
    end

    should "print . for a passing test" do
      adapter = Tack::StubAdapter.new
      test = Test.new('file.rb', ['Foo'], 'should do x')
      adapter.pass(test)
      assert_output_equals "Foo should do x: .\n" do |output|
        middleware = ProgressBar.new(adapter, :verbose => true, :output => output)
        middleware.run_test(test.to_basics)
      end
    end

    should "print F for a failing test" do
      adapter = Tack::StubAdapter.new
      test = Test.new('file.rb', ['Foo'], 'should do x')
      adapter.fail(test)
      assert_output_equals "Foo should do x: F\n" do |output|
        middleware = ProgressBar.new(adapter, :verbose => true, :output => output)
        middleware.run_test(test.to_basics)
      end
    end

  end

end
