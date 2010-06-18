require 'test_helper'

class RSpecAdapterTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Adapters

  context "getting tests" do

    should "get return all tests" do
      body = <<-EOS
      specify "something" do
      end

      it "should do something" do
      end
      EOS
      with_rspec_context :describe => String, :body => body do |path|
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
      with_rspec_context :describe => String, :body => body do |path|
        set = Tack::TestSet.new(path.parent)
        tests = set.tests_for(path)
        assert_equal 1, tests.length
        assert_equal [path.to_s, ["String", "sometimes", "in some cases"], "something"], tests.first
      end
    end
    
  end

  context "running tests" do
    
  end

end
