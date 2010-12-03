require 'test_helper'

class TestTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Util

  context "when initializing" do

    should "work with args" do
      test = Test.new('path',['Class','context'],'description')
      assert_equal 'path', test.path
      assert_equal ['Class','context'], test.contexts
      assert_equal 'description', test.description
    end

    should "work with args array" do
      test = Test.new(['path',['Class','context'],'description'])
      assert_equal 'path', test.path
      assert_equal ['Class','context'], test.contexts
      assert_equal 'description', test.description
    end

    should "work with args hash" do
      test = Test.new(:path => 'path',
                      :contexts => ['Class','context'],
                      :description => 'description')
      assert_equal 'path', test.path
      assert_equal ['Class','context'], test.contexts
      assert_equal 'description', test.description
    end

  end

  context "#to_basics" do
    
    should "be array containing path, contexts, and description" do
      basics_test = ['path',['Class','context'],'description']
      test = Test.new(basics_test)
      assert_equal basics_test, test.to_basics
    end

  end

  context"#name" do
    
    should "include contexts and description" do
      test = Test.new('path',['Class','sometimes'],'should do something')
      assert_equal 'Class sometimes should do something', test.name
    end
    
  end

end
