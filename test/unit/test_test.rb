require 'test_helper'

class TestTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Util

  context "when initializing" do

    should "work with args" do
      test = Test.new('file',['Class','context'],'description')
      assert_equal 'file', test.file
      assert_equal ['Class','context'], test.contexts
      assert_equal 'description', test.description
    end

    should "work with args array" do
      test = Test.new(['file',['Class','context'],'description'])
      assert_equal 'file', test.file
      assert_equal ['Class','context'], test.contexts
      assert_equal 'description', test.description
    end

    should "work with args hash" do
      test = Test.new(:file => 'file',
                      :contexts => ['Class','context'],
                      :description => 'description')
      assert_equal 'file', test.file
      assert_equal ['Class','context'], test.contexts
      assert_equal 'description', test.description
    end

  end

  context "#to_basics" do
    
    should "be array containing file, contexts, and description" do
      basics_test = ['file',['Class','context'],'description']
      test = Test.new(basics_test)
      assert_equal basics_test, test.to_basics
    end

  end

  context"#name" do
    
    should "include contexts and description" do
      test = Test.new('file',['Class','sometimes'],'should do something')
      assert_equal 'Class sometimes should do something', test.name
    end
    
  end

end
