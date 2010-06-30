require 'test_helper'

class TestUnitAdapterTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Adapters

  context "getting tests" do

    should "get return all tests" do
      body = <<-EOS
      def test_one
      end

      def test_two
      end
      EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        tests = TestUnitAdapter.new.tests_for(path)
        assert_equal 2, tests.length
        assert_equal [path.to_s, ["FakeTest"], "test_one"], tests.sort.first
        assert_equal [path.to_s, ['FakeTest'], "test_two"], tests.sort.last
      end
    end
    
  end

  context "running tests" do
    
    should "run a successful test" do
      body = <<-EOS
        def test_one
          assert_equal 1, 1
        end
        EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        test = [path.to_s, ['FakeTest'], "test_one"]
        results = Tack::ResultSet.new(TestUnitAdapter.new.run(*test))
        
        assert_equal 1, results.passed.length
        assert_equal 0, results.failed.length
        result = results.passed.first
        assert_equal Tack::Result.new(:test => test), result
      end
    end

    should "run a failing test" do
      body = <<-EOS
        def test_one
          assert_equal 1, 2
        end
        EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        test = [path.to_s, ['FakeTest'], "test_one"]
        results = Tack::ResultSet.new(TestUnitAdapter.new.run(*test))
        
        assert_equal 0, results.passed.length
        assert_equal 1, results.failed.length
        result = results.failed.first
        assert_equal test, result.test
        assert_equal "<1> expected but was\n<2>.", result.failure[:message]
        assert_kind_of Array, result.failure[:backtrace]
      end
    end

    should "run a test that raises an error" do
      body = <<-EOS
        def test_one
          raise "fail!!!"
        end
        EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        test = [path.to_s, ['FakeTest'], "test_one"]
        results = Tack::ResultSet.new(TestUnitAdapter.new.run(*test))
        
        assert_equal 0, results.passed.length
        assert_equal 1, results.failed.length
        result = results.failed.first
        assert_equal test, result.test
        assert_equal "RuntimeError was raised: fail!!!", result.failure[:message]
        assert_kind_of Array, result.failure[:backtrace]
      end
    end

    should "raise exception if test not found" do
      body = <<-EOS
        def test_one
        end
        EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        test = [path.to_s, ['FakeTest'], "test_two"]
        error = assert_raises Tack::NoMatchingTestError do
          TestUnitAdapter.new.run(*test)
        end
        assert_equal "No matching test found", error.message
      end
    end
    
  end

end
