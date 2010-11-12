require 'test_helper'

class RSpecAdapterTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Adapters

  should "should prevent auto-run at exit" do
    RSpecAdapter
    assert_equal true, ::RSpec::Core::Runner.autorun_disabled?
  end

  context "getting tests" do

    should "get return all tests" do
      body = <<-EOS
      specify "something" do
      end

      it "should do something" do
      end
      EOS
      in_rspec :describe => String, :body => body do |path|
        tests = RSpecAdapter.new.tests_for(path)
        assert_equal 2, tests.length
        assert_equal [path.to_s, ["String"], "something"], tests.first
        assert_equal [path.to_s, ["String"], "should do something"], tests.last
      end
    end

    should "handle nested contexts" do
      body = <<-EOS
      context "sometimes" do
        context "in some cases" do
          specify "something" do
          end
        end
      end
      EOS
      in_rspec :describe => String, :body => body do |path|
        tests = RSpecAdapter.new.tests_for(path)
        assert_equal 1, tests.length
        assert_equal [path.to_s, ["String", "sometimes", "in some cases"], "something"], tests.first
      end
    end
    
  end

  context "running tests" do
    
    context "without context" do

      should "not change test object" do
        body = <<-EOS
        specify "something" do
          1.should == 1
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String"], "something"]
          test_copy = deep_clone(test)
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          assert_equal test_copy, test
        end
      end

      
      should "run a successful test" do
        body = <<-EOS
        specify "something" do
          1.should == 1
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 1, results.passed.length
          assert_equal 0, results.failed.length
          result = results.passed.first
          assert_equal Tack::Result.new(:test => test), result
        end
      end

      should "run a failing test" do
        body = <<-EOS
        specify "something" do
          1.should == 2
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 0, results.passed.length
          assert_equal 1, results.failed.length
          result = results.failed.first
          assert_equal test, result.test
          assert_equal "expected: 2,\n     got: 1 (using ==)", result.failure[:message]
          assert_kind_of Array, result.failure[:backtrace]
        end
      end

      should "run a pending test" do
        body = <<-EOS
        specify "something" do
          pending
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 1, results.pending.length
          assert_equal 0, results.passed.length
          assert_equal 0, results.failed.length
          result = results.pending.first
          assert_equal Tack::Result.new(:test => test), result
        end
      end

      should "run a test that raises an error" do
        body = <<-EOS
        specify "something" do
          raise "fail!!!"
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
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
        specify "something" do
          1.should == 1
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String"], "should do something else"]
          error = assert_raises Tack::NoMatchingTestError do
            RSpecAdapter.new.run_test(test)
          end
          assert_equal %Q{Could not find test "String should do something else" in #{path}}, error.message
        end
      end
      
    end

    context "within context" do
      
      should "run a successful test" do
        body = <<-EOS
        context "sometimes" do
          specify "something" do
            1.should == 1
          end
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String", "sometimes"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 1, results.passed.length
          assert_equal 0, results.failed.length
          result = results.passed.first
          assert_equal Tack::Result.new(:test => test), result
        end
      end

      should "run a failing test" do
        body = <<-EOS
        context "sometimes" do
          specify "something" do
            1.should == 2
          end
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String", "sometimes"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 0, results.passed.length
          assert_equal 1, results.failed.length
          result = results.failed.first
          assert_equal test, result.test
          assert_not_nil result.failure
        end
      end

      should "run a pending test" do
        body = <<-EOS
        context "sometimes" do 
          specify "something" do
            pending
          end
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String", "sometimes"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 1, results.pending.length
          assert_equal 0, results.passed.length
          assert_equal 0, results.failed.length
          result = results.pending.first
          assert_equal Tack::Result.new(:test => test), result
        end
      end

      should "run a test that raises an error" do
        body = <<-EOS
        context "sometimes" do
          specify "something" do
            raise "fail!!!"
          end
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String", "sometimes"], "something"]
          results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
          assert_equal 0, results.passed.length
          assert_equal 1, results.failed.length
          result = results.failed.first
          assert_equal test, result.test
          assert_equal "RuntimeError was raised: fail!!!", result.failure[:message]
          assert_not_nil result.failure[:backtrace]
        end
      end

      context "when contexts have spaces" do
        
        should "run test" do
          body = <<-EOS
            context " sometimes" do
             it "should work" do
             end
            end
          EOS
          in_rspec :describe => String, :body => body do |path|
            test = [path.to_s, ['String', " sometimes"], "should work"]
            results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
            assert_equal 1, results.length
          end
        end

      end

      context "when contexts refer to methods" do
        
        should "run test for context that refers to instance method" do
          body = <<-EOS
            context "#join" do
             it "should work" do
             end
            end
          EOS
          in_rspec :describe => String, :body => body do |path|
            test = [path.to_s, ['String', "#join"], "should work"]
            results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
            assert_equal 1, results.length
          end
        end

        should "run test for context that refers to class method" do
          body = <<-EOS
            context ".new" do
             it "should work" do
             end
            end
          EOS
          in_rspec :describe => String, :body => body do |path|
            test = [path.to_s, ['String', ".new"], "should work"]
            results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
            assert_equal 1, results.length
          end
        end

      end

      context "when two contexts have identically named tests" do

        should "only run specified test" do
          body = <<-EOS
            context "sometimes" do
             it "should pass" do
             end
            end
            context "other times" do
             it "should pass" do
             end
            end
          EOS
          in_rspec :describe => String, :body => body do |path|
            test = [path.to_s, ['String', "sometimes"], "should pass"]
            results = Tack::ResultSet.new(RSpecAdapter.new.run_test(test))
          
            assert_equal 1, results.length
            assert_equal ['String', 'sometimes'], results.passed.first.test[1]
          end
        end

      end

      should "raise exception if test not found" do
        body = <<-EOS
        context "sometimes" do
          specify "something" do
            1.should == 1
          end
        end
        EOS
        in_rspec :describe => String, :body => body do |path|
          test = [path.to_s, ["String", "sometimes"], "should do something else"]
          error = assert_raises Tack::NoMatchingTestError do
            RSpecAdapter.new.run_test(test)
          end
          assert_equal %Q{Could not find test "String sometimes should do something else" in #{path}}, error.message
        end
      end
      
    end

  end

end
