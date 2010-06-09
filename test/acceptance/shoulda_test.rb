#require 'test_helper'

class ShouldaTest < Test::Unit::TestCase
  include TestHelpers
  
  should "grab all tests" do
    body =<<-EOS
       should "do something 2" do
       end

       should "do something 1" do
       end
     EOS
    with_test_class(:body => body, :class_name => 'FooTest') do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, "FooTest", "test: Foo should do something 1. "], tests.first
      assert_equal [file_name, "FooTest", "test: Foo should do something 2. "], tests.last
    end
  end
  
  should "foo" do
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
      assert_equal [file_name, "FooTest", "test: Foo should do something else. "], tests.first
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
      assert_equal [file_name, "FooTest", "test: in some context should do something. "], tests.first
    end
  end

end
