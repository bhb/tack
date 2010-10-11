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
    
    should "not change test object" do
      body = <<-EOS
      def test_one
        assert_equal 1, 1
      end
      EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        test = [path.to_s, ['FakeTest'], "test_one"]
        test_copy = deep_clone(test)
        results = Tack::ResultSet.new(TestUnitAdapter.new.run_test(*test))
        assert_equal test_copy, test
      end
    end

    should "run a successful test" do
      body = <<-EOS
      def test_one
        assert_equal 1, 1
      end
      EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        test = [path.to_s, ['FakeTest'], "test_one"]
        results = Tack::ResultSet.new(TestUnitAdapter.new.run_test(*test))
        
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
        results = Tack::ResultSet.new(TestUnitAdapter.new.run_test(*test))
        
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
        results = Tack::ResultSet.new(TestUnitAdapter.new.run_test(*test))
        
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
          TestUnitAdapter.new.run_test(*test)
        end
        assert_equal %Q{Could not find test "FakeTest test_two" in #{path}}, error.message
      end
    end
    
  end

  
  context "handling #default_test" do

    context "when there are no tests" do

      context "when #default_test not implemented" do

        should "report one test and one failure" do
          body = <<-EOS
          # no tests
          EOS
          with_test_class :body => body do |_, path|
            adapter = TestUnitAdapter.new
            tests = adapter.tests_for(path)
            results = Tack::ResultSet.new
            tests.each do |test|
              results.merge(Tack::ResultSet.new(adapter.run_test(*test)))
            end
            assert_equal 1, results.length
            assert_equal 1, results.failed.length
          end
        end
      end

      context "when #default_test implemented" do
        
        should "report one test" do
          body = <<-EOS
          def default_test; assert true; end;
          EOS
          with_test_class :body => body do |_, path|
            adapter = TestUnitAdapter.new
            tests = adapter.tests_for(path)
            results = Tack::ResultSet.new
            tests.each do |test|
              results.merge(Tack::ResultSet.new(adapter.run_test(*test)))
            end
            assert_equal 1, results.length
            assert_equal 1, results.passed.length
          end
        end
      end
      
    end

    context "when there are tests" do

      context "when #default_test is implemented" do
        
        should "report number of tests, not including #default_test" do
          body = <<-EOS
          def default_test; assert true; end;
          def test_one; end;
          def test_two; end;
          EOS
          with_test_class :body => body do |_, path|
            adapter = TestUnitAdapter.new
            tests = adapter.tests_for(path)
            # TODO - this is really awkward to run tests directly
            results = Tack::ResultSet.new
            tests.each do |test|
              results.merge(Tack::ResultSet.new(adapter.run_test(*test)))
            end
            assert_equal 2, results.length
          end
        end

      end

    end

  end

  context "in a testcase in a module" do

    should "find and run tests" do
      begin
        body =<<-EOS
        require 'test/unit'
      
        module FooModule
          class BarTest < Test::Unit::TestCase
            def test_foo
            end
          end
        end
        EOS
        within_construct(false) do |c|
          adapter = TestUnitAdapter.new
          test_file = c.file('foo_test.rb',body)
          tests = adapter.tests_for(test_file)
          assert_equal [[test_file.to_s,['FooModule::BarTest'],'test_foo']], tests
          results = adapter.run_test(*tests.first)
          assert_equal 1, results[:passed].length
        end
      ensure 
        remove_test_class_definition("FooModule::BarTest".to_sym)
      end
    end
  end

end
