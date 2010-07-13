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
      with_test_class :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 2, tests.length
        assert_equal [file_name, ["StringTest"], "do something"], tests.first
        assert_equal [file_name, ["StringTest"], "do something else"], tests.last
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
      with_test_class :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 1, tests.length
        assert_equal [file_name, ["StringTest", "sometimes", "in some cases"], "do something"], tests.first
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
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      tests = ShouldaAdapter.new.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, ["FooTest", "in some context"], "do something"], tests.first
      assert_equal [file_name, ["FooTest", "in some other context"], "do something"], tests.last
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
      with_test_class :class_name => :StringTest, :body => body do |file_name, path|
        tests = ShouldaAdapter.new.tests_for(path)
        assert_equal 2, tests.length
        assert_equal [file_name, ["StringTest"], "do something"], tests.first
        assert_equal [file_name, ["StringTest", "sometimes"], "do something else"], tests.last
      end      
    end
    
  end

  context "running tests" do
    
    context "without context" do
      
      should "run a successful test" do
        body = <<-EOS
        should "do something" do
          assert_equal 2, 1+1
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "do something"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          assert_equal 1, results.passed.length
          assert_equal 0, results.failed.length
          result = results.passed.first
          assert_equal Tack::Result.new(:test => test), result
        end
      end

      should "run a failing test" do
        body = <<-EOS
        should "fail" do
          assert_equal 2, 1-1
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "fail"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
          assert_equal 0, results.passed.length
          assert_equal 1, results.failed.length
          result = results.failed.first
          assert_equal test, result.test
          assert_equal "<2> expected but was\n<0>.", result.failure[:message]
          assert_kind_of Array, result.failure[:backtrace]
        end
      end

      should "run a pending test" do
        body = <<-EOS
        should_eventually "do something" do
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "do something"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          assert_equal 1, results.pending.length
          assert_equal 0, results.passed.length
          assert_equal 0, results.failed.length
          result = results.pending.first
          assert_equal Tack::Result.new(:test => test), result
        end
      end

      should "run a test that raises an error" do
        body = <<-EOS
        should "raise error" do
          raise "fail!!!"
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "raise error"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
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
        should "do something" do
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest"], "another spec"]
          error = assert_raises Tack::NoMatchingTestError do
            ShouldaAdapter.new.run(*test)
          end
          assert_equal "No matching test found", error.message
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
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "do something"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
          assert_equal 1, results.passed.length
          assert_equal 0, results.failed.length
          result = results.passed.first
          assert_equal Tack::Result.new(:test => test), result
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
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "do something"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
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
          should_eventually "do something" do
          end
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "do something"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
          assert_equal 1, results.pending.length
          assert_equal 0, results.passed.length
          assert_equal 0, results.failed.length
          result = results.pending.first
          assert_equal Tack::Result.new(:test => test), result
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
          with_test_class :class_name => :StringTest, :body => body do |file_name, path|
            test = [file_name, ["StringTest", "String"], "do something"]
            results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
            assert_equal 1, results.passed.length
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
           with_test_class :class_name => :StringTest, :body => body do |file_name, path|
             test = [file_name, ["StringTest", "String"], "do something"]
             results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
           
             assert_equal 1, results.pending.length
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
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "other times"], "do something"]
          error = assert_raises Tack::NoMatchingTestError do
            ShouldaAdapter.new.run(*test)
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
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes", "in some cases"], "do something"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
          assert_equal 1, results.pending.length
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
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "raise an error"]
          results = Tack::ResultSet.new(ShouldaAdapter.new.run(*test))
          
          assert_equal 0, results.passed.length
          assert_equal 1, results.failed.length
          result = results.failed.first
          assert_equal test, result.test
          assert_equal "RuntimeError was raised: fail!!!", result.failure[:message]
          assert_not_nil result.failure[:backtrace]
        end
      end

      should "raise exception if test not found" do
        body = <<-EOS
        context "sometimes" do
          should "do something" do
          end
        end
        EOS
        with_test_class :class_name => :StringTest, :body => body do |file_name, path|
          test = [file_name, ["StringTest", "sometimes"], "another spec"]
          error = assert_raises Tack::NoMatchingTestError do
            ShouldaAdapter.new.run(*test)
          end
          assert_equal "No matching test found", error.message
        end
      end
      
    end

  end

end
