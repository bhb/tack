require 'test_helper'

class ShouldaTest < Test::Unit::TestCase
  include TestHelpers
  
  should "grab all tests" do
    body =<<-EOS
       should "do something 1" do
       end

       should "do something 2" do
       end
     EOS
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, ["FooTest"], "do something 1"], tests.first
      assert_equal [file_name, ["FooTest"], "do something 2"], tests.last
    end
  end
  
  should "grab all tests matching pattern" do
    body =<<-EOS
       should "do something" do
       end
     
       should "do something else" do
       end
     EOS
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, /else/)
      assert_equal 1, tests.length
      assert_equal [file_name, ["FooTest"], "do something else"], tests.first
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
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, ["FooTest", "in some context"], "do something"], tests.first
      assert_equal [file_name, ["FooTest", "in some other context"], "do something"], tests.last
    end
  end

  should "include nested contexts" do
    body =<<-EOS
      context "in some context" do
        should "do something" do
        end

        context "in some subcontext" do

          should "do something special" do
          end

        end
      end

      context "in some other context" do
        should "do something else" do
        end
      end
    EOS
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 3, tests.length
      assert_equal [file_name, ["FooTest", "in some context"], "do something"], tests[0]
      assert_equal [file_name, ["FooTest", "in some context", "in some subcontext"], "do something special"], tests[1]
      assert_equal [file_name, ["FooTest", "in some other context"], "do something else"], tests[2]
    end
  end

  should "grab all tests in contexts that match pattern" do
    body =<<-EOS
      context "in some context" do
        should "do something" do
        end
      end
    EOS
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, /in some context/)
      assert_equal 1, tests.length
      assert_equal [file_name, ["FooTest", "in some context"], "do something"], tests.first
    end
  end

  should "run succesful test" do
    body =<<-EOS
      should "pass" do
        assert_equal 2, 1+1
      end
    EOS
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)

      assert_equal 1, results[:passed].length
      assert_equal 0, results[:failed].length
      assert_equal [file_name, ["FooTest"], "pass"], results[:passed].first[:test]
    end
  end

  context "in a Shoulda context" do

    should "run successful test" do
      body =<<-EOS
      context "in some context" do
        should "pass" do
          assert_equal 2, 1+1
        end
      end
    EOS
      with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
        set = Tack::TestSet.new(path.parent)
        tests = set.tests_for(path)
        runner = Tack::Runner.new(path.parent)
        results = runner.run(tests)

        assert_equal 1, results[:passed].length
        assert_equal 0, results[:failed].length
        assert_equal "pass", results[:passed].first[:test].last
      end
    end

    should "run failing test" do
      body =<<-EOS
      context "in some context" do
        should "flunk" do
          flunk
        end
      end
      EOS
      with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
        set = Tack::TestSet.new(path.parent)
        tests = set.tests_for(path)
        runner = Tack::Runner.new(path.parent)
        results = runner.run(tests)

        assert_equal 0, results[:passed].length
        assert_equal 1, results[:failed].length
        assert_equal [file_name, ["FooTest", "in some context"], "flunk"], results[:failed].first[:test]
      end
    end

  end

end
