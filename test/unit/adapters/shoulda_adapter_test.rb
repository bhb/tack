require 'test_helper'

class ShouldaAdapterTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Adapters

  context "getting tests" do

    should "get return all tests" do
      body = <<-EOS
      should "do something" do
      end

      should "do something else" do
      end
      EOS
      with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 2, tests.length
        assert_equal [file_name, ["StringTest"], "should do something"], tests.first
        assert_equal [file_name, ["StringTest"], "should do something else"], tests.last
      end
    end

    should "return tests in alphabetical order" do
      body = <<-EOS
      should "do z" do; end;
      should "do aa" do; end;
      should "do a" do; end;
      EOS
      with_shoulda_test :class_name => :StringTest, :body => body do |_, path|
        tests = TestUnitAdapter.new.tests_for(path)
        descriptions = tests.map do |_,_,desc| 
          desc.gsub('test: String should ','').gsub('. ','')
        end
        assert_equal ["do a", "do aa", "do z"], descriptions
      end
    end

    should "handle nested contexts" do
      body = <<-EOS
      context "sometimes" do
        context "in some cases" do
          should "do something" do
          end
        end
      end
      EOS
      with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 1, tests.length
        assert_equal [file_name, ["StringTest", "sometimes", "in some cases"], "should do something"], tests.first
      end
    end

    should "differentiate between identically named tests with different contexts" do
      body =<<-EOS
      context "in some context" do
        should "do something" do
        end
      end

      context "in some other context" do
        should "do something" do
        end
      end
    EOS
    with_shoulda_test(:body => body, :class_name => 'FooTest') do |file_name, path|
      tests = ShouldaAdapter.new.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, ["FooTest", "in some context"], "should do something"], tests.first
      assert_equal [file_name, ["FooTest", "in some other context"], "should do something"], tests.last
      end
    end

    should "return pending tests" do
      body = <<-EOS
      should_eventually "do something" do
      end

      context "sometimes" do
        should_eventually "do something else" do
        end
      end
      EOS
      with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 2, tests.length
        assert_equal [file_name, ["StringTest"], "should do something"], tests.first
        assert_equal [file_name, ["StringTest", "sometimes"], "should do something else"], tests.last
      end      
    end

    should "return pending tests in nested contexts" do
      body = <<-EOS
      context "sometimes" do
        context "in some cases" do
          should_eventually "do something else" do
          end
        end
      end
      EOS
      with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 1, tests.length
        assert_equal [file_name, ["StringTest", "sometimes", "in some cases"], "should do something else"], tests.last
      end      
    end

    context "when test class starts with 'Test'" do
      
      should "return test name correctly" do
        body = <<-EOS
          should "do something" do
          end
        EOS
        with_shoulda_test :class_name => :TestFooTest, :body => body do |file_name, path|
          tests = ShouldaAdapter.new.tests_for(path)
          assert_equal [file_name, ['TestFooTest'], 'should do something'], tests.first
        end
      end

    end

  end

  context "ordering tests" do
    
    should "order by contexts" do
      tests = [["foo_test.rb", ["FooTest", "context"], "verify foo"],
               ["bar_test.rb", ["BarTest", "context"], "verify bar"],
               ["baz_test.rb", ["BazTest", "context2"], "verify baz"],
               ["baz_test.rb", ["BazTest", "context1"], "verify baz"]]
      expected_order = [["bar_test.rb", ["BarTest", "context"], "verify bar"],
                        ["baz_test.rb", ["BazTest", "context1"], "verify baz"],
                        ["baz_test.rb", ["BazTest", "context2"], "verify baz"],
                        ["foo_test.rb", ["FooTest", "context"], "verify foo"]]
      assert_equal expected_order, TestUnitAdapter.new.order(tests)
    end

    should "keep test names sorted alphabetically" do
      tests = [["foo_test.rb", ["FooTest", "context"], "verify foo"],
               ["bar_test.rb", ["BarTest", "context"], "verify bar 1"],
               ["bar_test.rb", ["BarTest", "context"], "verify bar 2"]]
      expected_order = [["bar_test.rb", ["BarTest", "context"], "verify bar 1"],
                        ["bar_test.rb", ["BarTest", "context"], "verify bar 2"],
                        ["foo_test.rb", ["FooTest", "context"], "verify foo"]]
      assert_equal expected_order, TestUnitAdapter.new.order(tests)
    end

  end

  context "running tests" do
    
    context "without context" do

      should "not change test object" do
        body = <<-EOS
        should "do something" do
          assert_equal 2, 1+1
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          adapter = ShouldaAdapter.new
          test = [file_name, ["StringTest"], "should do something"]
          test_copy = deep_clone(test)
          adapter.run_test(test)
          assert_equal test_copy, test
        end
      end
      
      should "run a successful test" do
        body = <<-EOS
        should "do something" do
          assert_equal 2, 1+1
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          adapter = ShouldaAdapter.new
          test = [file_name, ["StringTest"], "should do something"]
          result = adapter.run_test(test)
          assert_equal :passed, result[:status]
          assert_equal test, result[:test]
        end
      end

      should "run a failing test" do
        body = <<-EOS
        should "fail" do
          assert_equal 2, 1-1
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "should fail"]
          result = ShouldaAdapter.new.run_test(test)
          
          assert_equal :failed, result[:status]
          assert_equal test, result[:test]
          assert_equal "<2> expected but was\n<0>.", result[:failure][:message]
          assert_kind_of Array, result[:failure][:backtrace]
        end
      end

      should "run a pending test" do
        body = <<-EOS
        should_eventually "do something" do
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "should do something"]
          result = ShouldaAdapter.new.run_test(test)
          assert_equal :pending, result[:status]
          assert_equal test, result[:test]
        end
      end

      should "run a test that raises an error" do
        body = <<-EOS
        should "raise error" do
          raise "fail!!!"
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "should raise error"]
          result = ShouldaAdapter.new.run_test(test)
          
          assert_equal :failed, result[:status]
          assert_equal test, result[:test]
          assert_equal "RuntimeError was raised: fail!!!", result[:failure][:message]
          assert_kind_of Array, result[:failure][:backtrace]
        end
      end

      should "raise exception if test not found" do
        body = <<-EOS
        should "do something" do
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "should do something else"]
          error = assert_raises Tack::NoMatchingTestError do
            ShouldaAdapter.new.run_test(test)
          end
          assert_equal %Q{Could not find test "StringTest should do something else" in #{path}}, error.message
        end
      end
      
    end

    context "within context" do
      
      should "run a successful test" do
        body = <<-EOS
        context "sometimes" do
          should "do something" do
            assert_equal 2, 1+1
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "should do something"]
          result = ShouldaAdapter.new.run_test(test)

          assert_equal :passed, result[:status]
          assert_equal test, result[:test]          
        end
      end

      should "run a failing test" do
        body = <<-EOS
        context "sometimes" do
          should "do something" do
            assert_equal 2, 1-1
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "should do something"]
          result = ShouldaAdapter.new.run_test(test)
          
          assert_equal :failed, result[:status]
          assert_equal test, result[:test]
          assert_not_nil result[:failure]
        end
      end

      should "run a pending test" do
        body = <<-EOS
        context "sometimes" do 
          should_eventually "do something" do
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "should do something"]
          result = ShouldaAdapter.new.run_test(test)
          
          assert_equal :pending, result[:status]
          assert_equal test, result[:test]
        end
      end

      context "with identical context name" do
        
        should "run a successful test" do
          body = <<-EOS
          context "String" do
            should "do something" do
              assert_equal 2, 1+1
            end
          end
          EOS
          with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
            test = [file_name, ["StringTest", "String"], "should do something"]
            result = ShouldaAdapter.new.run_test(test)
          
            assert_equal :passed, result[:status]
            assert_equal test, result[:test]
          end
        end

        # This is a known bug. There doesn't appear to be a way to easily
        # catch this case with the current Shoulda code. I may have to 
        # do some fancy monkey patching to make this work, but it's a rare
        # case, so I'm punting for now.
        should_eventually "run a pending test" do
           body = <<-EOS
           context "String" do 
             should_eventually "do something" do
             end
           end
           EOS
           with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
             test = [file_name, ["StringTest", "String"], "should do something"]
             result = ShouldaAdapter.new.run_test(test)
           
             assert_equal :pending, result[:status]
           end
         end
      end

      should "raise an error when running a pending test from another context" do
        body = <<-EOS
        context "sometimes" do 
          should_eventually "do something" do
          end
        end
        context "other times" do
          should_eventually "do something else" do
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "other times"], "should do something"]
          error = assert_raises Tack::NoMatchingTestError do
            ShouldaAdapter.new.run_test(test)
          end
        end
      end

      should "handle nested contexts with pending tests" do
        body = <<-EOS
        context "sometimes" do
          context "in some cases" do   
            should_eventually "do something" do
            end
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes", "in some cases"], "should do something"]
          result = ShouldaAdapter.new.run_test(test)
          
          assert_equal :pending, result[:status]
        end
      end

      should "run a test that raises an error" do
        body = <<-EOS
        context "sometimes" do
          should "raise an error" do
            raise "fail!!!"
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "should raise an error"]
          result = ShouldaAdapter.new.run_test(test)
          
          assert_equal :failed, result[:status]
          assert_equal test, result[:test]
          assert_equal "RuntimeError was raised: fail!!!", result[:failure][:message]
          assert_not_nil result[:failure][:backtrace]
        end
      end

      should "raise exception if test not found" do
        body = <<-EOS
        context "sometimes" do
          should "do something" do
          end
        end
        EOS
        with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "should do something else"]
          error = assert_raises Tack::NoMatchingTestError do
            ShouldaAdapter.new.run_test(test)
          end
          assert_equal %Q{Could not find test "StringTest sometimes should do something else" in #{path}}, error.message
        end
      end
      
    end

  end

  # This happens in the Jeweler test suite
  context "with '' context" do
    
    should "run a successful test" do
      body = <<-EOS
      context "sometimes" do
        context "" do
          should "do something" do
            assert_equal 2, 1+1
          end
        end
      end
      EOS
      with_shoulda_test :class_name => :StringTest, :body => body do |file_name, path|
        adapter = ShouldaAdapter.new
        test = adapter.tests_for(path).first
        assert_equal [file_name, ["StringTest", "sometimes"], "should do something"], test
        result = adapter.run_test(test)

        assert_equal :passed, result[:status]
        assert_equal test, result[:test]
      end
    end

  end

  context "loading tests" do

    should "not print 'already initialized constant' warnings" do
      body = <<-EOS
        CONSTANT = 1

        should "do something" do; end;
        should "do something else" do; end;
      EOS
      with_shoulda_test :body => body do |file_name, path|
        test1 = [file_name, ["StringTest"], "should do something"]
        test2 = [file_name, ["StringTest"], "should do something"]
        adapter = ShouldaAdapter.new
        stdout, stderr = capture_io do
          adapter.run_test(test1)
          adapter.run_test(test2)
        end
        assert_no_match /warning: already initialized constant/, stdout
        assert_no_match /warning: already initialized constant/, stderr
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
          with_shoulda_test :body => body do |_, path|
            tests = ShouldaAdapter.new.tests_for(path)
            results = Tack::Util::ResultSet.new(ShouldaAdapter.new.run_suite(tests))
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
          with_shoulda_test :body => body do |_, path|
            tests = ShouldaAdapter.new.tests_for(path)
            results = Tack::Util::ResultSet.new(ShouldaAdapter.new.run_suite(tests))
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
          should "do something" do; end;
          should "do something else" do; end;
          EOS
          with_shoulda_test :body => body do |_, path|
            tests = ShouldaAdapter.new.tests_for(path)
            results = Tack::Util::ResultSet.new(ShouldaAdapter.new.run_suite(tests))
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
        require 'shoulda'
      
        module FooModule
          class BarTest < Test::Unit::TestCase
            should "do something" do
            end
          end
        end
        EOS
        within_construct(false) do |c|
          adapter = ShouldaAdapter.new
          test_file = c.file('foo_test.rb',body)
          tests = adapter.tests_for(test_file)
          assert_equal [[test_file.to_s,['FooModule::BarTest'],'should do something']], tests
          result = adapter.run_test(tests.first)
          assert_equal :passed, result[:status]
        end
      ensure 
        remove_test_class_definition("FooModule::BarTest".to_sym)
      end
    end
  end
     
end
