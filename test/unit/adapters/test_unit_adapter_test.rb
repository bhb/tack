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

    should "return tests in alphabetical order" do
      body = <<-EOS
      def test_z;end
      def test_aa;end
      def test_a;end
      EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        tests = TestUnitAdapter.new.tests_for(path)
        descriptions = tests.map { |_,_,desc| desc.gsub('test_','') }
        assert_equal %w{a aa z}, descriptions
      end
    end

    
  end

  context "ordering tests" do
    
    should "order by testcase name" do
      tests = [["foo_test.rb", ["FooTest"], "test_foo"],
               ["bar_test.rb", ["BarTest"], "test_bar"],
               ["baz_test.rb", ["BazTest"], "test_baz"]]
      expected_order = [["bar_test.rb", ["BarTest"], "test_bar"],
                        ["baz_test.rb", ["BazTest"], "test_baz"],
                        ["foo_test.rb", ["FooTest"], "test_foo"]]
      assert_equal expected_order, TestUnitAdapter.new.order(tests)
    end

    should "keep test names sorted alphabetically" do
      tests = [["foo_test.rb", ["FooTest"], "test_foo"],
               ["bar_test.rb", ["BarTest"], "test_1"],
               ["bar_test.rb", ["BarTest"], "test_2"]]
      expected_order = [["bar_test.rb", ["BarTest"], "test_1"],
                        ["bar_test.rb", ["BarTest"], "test_2"],
                        ["foo_test.rb", ["FooTest"], "test_foo"]]
      assert_equal expected_order, TestUnitAdapter.new.order(tests)
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
        TestUnitAdapter.new.run_test(test)
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
        result = Tack::Util::Result.new(TestUnitAdapter.new.run_test(test))
        
        assert_equal :passed, result.status
        assert_equal test, result.test
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
        result = Tack::Util::Result.new(TestUnitAdapter.new.run_test(test))
        
        assert_equal :failed, result.status
        assert_equal test, result.test
        assert_equal "<1> expected but was\n<2>.", result.failure[:message]
        assert_kind_of Array, result.failure[:backtrace]
      end
    end

    should "run two failing tests and report respective errors" do
      body = <<-EOS
      def test_one
        assert_equal 1, 2
      end
      def test_two
        assert_equal 3, 4
      end
      EOS
      with_test_class :class_name => 'FakeTest', :body => body do |_, path|
        adapter = TestUnitAdapter.new

        test = [path.to_s, ['FakeTest'], "test_one"]
        result = Tack::Util::Result.new(adapter.run_test(test))
        
        assert_equal "<1> expected but was\n<2>.", result.failure[:message]

        test = [path.to_s, ['FakeTest'], "test_two"]
        result = Tack::Util::Result.new(adapter.run_test(test))
        assert_equal "<3> expected but was\n<4>.", result.failure[:message]
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
        result = ::Tack::Util::Result.new(TestUnitAdapter.new.run_test(test))
        
        assert_equal :failed, result.status
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
          TestUnitAdapter.new.run_test(test)
        end
        assert_equal %Q{Could not find test "FakeTest test_two" in #{path}}, error.message
      end
    end
    
  end

  context "when Rails is loaded" do
    
    context "when default_test is not defined" do
      
      should "not report #default_test" do
        begin
          ::Rails = Module.new
          body = <<-EOS
          # no tests
          EOS
          with_test_class :body => body do |_, path|
            adapter = TestUnitAdapter.new
            tests = adapter.tests_for(path)
            assert_equal 0, tests.length
            results = Tack::Util::ResultSet.new(adapter.run_suite(tests))
            assert_equal 0, results.length
          end
        ensure
          remove_test_class_definition("Rails".to_sym)
          assert !defined?(Rails)
        end
      end
    end

    context "when default_test is defined" do
      
      should "not report #default_test" do
        begin
          ::Rails = Module.new
          body = <<-EOS
          def default_test
          end
          EOS
          with_test_class :body => body do |_, path|
            adapter = TestUnitAdapter.new
            tests = adapter.tests_for(path)
            assert_equal 0, tests.length
            results = Tack::Util::ResultSet.new(adapter.run_suite(tests))
            assert_equal 0, results.length
          end
        ensure
          remove_test_class_definition("Rails".to_sym)
          assert !defined?(Rails)
        end
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
            results = Tack::Util::ResultSet.new(adapter.run_suite(tests))
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
            results = Tack::Util::ResultSet.new(adapter.run_suite(tests))
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
            results = adapter.run_suite(tests)
            assert_equal 2, Tack::Util::ResultSet.new(results).length
          end
        end

      end

    end

    context "with subclass of Test::Unit::TestCase" do

      context "when #default_test is undefined" do
        
        should "report number of tests not including #default_test" do
          begin
            body = <<-EOS
            require 'test/unit'
            class SpecialTestCase < Test::Unit::TestCase
              undef :default_test
            end

            class MyTest < SpecialTestCase
              def test_one; end
            end
            EOS
            within_construct(false) do |c|
              adapter = TestUnitAdapter.new
              test_file = c.file('my_test.rb',body)
              tests = adapter.tests_for(test_file)
              assert_equal [[test_file.to_s,['MyTest'],'test_one']], tests
            end
          ensure 
            remove_test_class_definition("SpecialTestCase".to_sym)
            remove_test_class_definition("MyTest".to_sym)
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
          result = adapter.run_test(tests.first)
          assert_equal :passed, result[:status]
        end
      ensure 
        remove_test_class_definition("FooModule::BarTest".to_sym)
      end
    end
  end

end
