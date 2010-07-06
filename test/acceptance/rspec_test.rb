require 'test_helper'

class RSpecTest < Test::Unit::TestCase
  include TestHelpers

   should "run specs that match substring" do
    body = <<-EOS
    specify "something" do
    end

    it "does nothing" do
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path, "some")
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.length
    end
  end

  should "run specs that match regular expression" do
    body = <<-EOS
    specify "something" do
    end

    it "does nothing" do
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path, /does/)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.length
    end
  end

  should "run specs that are in context which matches regexp" do
    body = <<-EOS
    context "sometimes" do
      context "in some cases" do

        specify "something" do
        end

        specify "another thing" do
        end

      end
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path, /cases/)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 2, result_set.length
    end
  end

  should "run failing spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      ("ab"+"cd").length.should == ("ab".length - "cd".length)
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.failed.length
    end
  end

  should "run pending spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      pending
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.pending.length
    end
  end

  should "run spec that raises error" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      raise "failing!"
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.failed.length
    end
  end

  should "run successful spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      ("ab"+"cd").length.should == ("ab".length + "cd".length)
    end
    EOS
    in_rspec :body => body do |path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.passed.length
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
      in_rspec :body => body do |path|
        raw_results = Tack::Runner.run_tests(path.parent, path)
        result_set = Tack::ResultSet.new(raw_results)
        assert_equal 1, result_set.passed.length
      end
    end

  end

end
