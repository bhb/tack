require 'test_helper'

class RSpecTest < Test::Unit::TestCase
  include TestHelpers

  should "grab all specs" do
    body = <<-EOS
    specify "something" do
    end

    it "should do something" do
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [path.to_s, ["String"], "should do something"], tests.first
      assert_equal [path.to_s, ["String"], "something"], tests.last
    end
  end

  should "find specs that match substring" do
    body = <<-EOS
    specify "something" do
    end

    it "does nothing" do
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, "some")
      assert_equal 1, tests.length
      assert_equal [path.to_s, ["String"], "something"], tests.first
    end
  end

  should "find specs that match regular expression" do
    body = <<-EOS
    specify "something" do
    end

    it "does nothing" do
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, /does/)
      assert_equal 1, tests.length
      assert_equal [path.to_s, ["String"], "does nothing"], tests.first
    end
  end

  should "find specs that are in context which matches regexp" do
    body = <<-EOS
    context "sometimes" do
      context "in some cases" do

        specify "something" do
        end

      end
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, /cases/)
      assert_equal 1, tests.length
      assert_equal [path.to_s, ["String", "sometimes", "in some cases"], "something"], tests.first
    end
  end

  should "run failing spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      ("ab"+"cd").length.should == ("ab".length - "cd".length)
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      
      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length
      result = results[:failed].first
      assert_equal [path.to_s, ["String"], "append length is sum of component string lengths"], result[:test]
      assert_equal "expected: 0,\n     got: 4 (using ==)", result[:failure][:message]
      assert_kind_of Array, result[:failure][:backtrace]
    end
  end

  should "run spec that raises error" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      raise "failing!"
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      
      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length

      result = results[:failed].first
      assert_equal [path.to_s, ["String"], "append length is sum of component string lengths"], result[:test]
      assert_match /was raised/, result[:failure][:message]
      assert_kind_of Array, result[:failure][:backtrace]
    end
  end

  should "run successful spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      ("ab"+"cd").length.should == ("ab".length + "cd".length)
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      
      assert_equal 1, results[:passed].length
      assert_equal 0, results[:failed].length
      assert_equal [path.to_s, ["String"], "append length is sum of component string lengths"], results[:passed].first[:test]
    end
  end

  context "in a context" do
    
    should "run successful spec" do
      body = <<-EOS
        context "in all cases" do
          specify "append length is sum of component string lengths" do
            ("ab"+"cd").length.should == ("ab".length + "cd".length)
          end
        end
      EOS
      with_rspec_context :describe => String, :body => body do |path|
        set = Tack::TestSet.new(path.parent)
        tests = set.tests_for(path)
        runner = Tack::Runner.new(path.parent)
        results = runner.run(tests)
        
        assert_equal 1, results[:passed].length
        assert_equal 0, results[:failed].length
        assert_equal [path.to_s, ["String", "in all cases"], "append length is sum of component string lengths"], results[:passed].first[:test]
      end
    end

  end

end
