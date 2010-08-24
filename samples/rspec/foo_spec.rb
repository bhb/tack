$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'foo'
require 'spec'

def passing_spec
  true.should == true
end

def failing_spec
  flunk
end

def error!
  raise "Error!"
end

describe Foo do

  describe "basic cases" do
    
    it "should pass" do
      passing_spec
    end

    it "should fail" do
      failing_spec
    end

    it "should be pending" do
      pending
    end

  end

  describe "with before(:each)" do
    
    before :each do
      @it = Foo.new
    end

    it "should pass" do
      @it.bar.should == "bar"
    end

    it "should fail" do
      @it.bar.should == "baz"
    end

  end

  describe "with before(:all)" do
    
    before :all do
      @it = Foo.new
    end

    it "should pass" do
      @it.bar.should == "bar"
    end

    it "should fail" do
      @it.bar.should == "baz"
    end

  end

  describe "with after(:each)" do

    after :each do
      @it.bar
    end

    it "should pass" do
      @it = Foo.new
      @it.bar.should == "bar"
    end

    it "should fail" do
      @it = Foo.new
      @it.bar.should == "baz"
    end
    
  end

  describe "with after(:all)" do

    after :all do
      @it.bar
    end

    it "should pass" do
      @it = Foo.new
      @it.bar.should == "bar"
    end

    it "should fail" do
      @it = Foo.new
      @it.bar.should == "baz"
    end
    
  end

  describe "failure in before :each" do
    
    before :each do
      error!
    end
    
    it "should pass" do
      passing_spec
    end
    
  end

  describe "failure in after :each" do
    
    after :each do 
      error!
    end
    
    it "should pass" do
      passing_spec
    end

  end

  describe "failure in before :all" do
    
    before :all do
      error!
    end

    it "should pass" do
      passing_spec
    end
    
  end

  describe "failure in after :all" do
    
    after :all do
      error!
    end

    it "should pass" do
      passing_spec
    end
    
  end

  describe "#baz" do

    it "should fail due to undefined method" do
      Foo.new.baz.should == "meow"
    end
    
  end
  
  shared_examples_for "it's using a shared example" do
    
    it "should pass with" do
      passing_spec
    end

    it "should fail" do
      failing_spec
    end

    it "should error" do
      error!
    end

    it "should be pending" do
      pending
    end
    
  end

  describe "something that uses a shared example" do
    
    it_should_behave_like "it's using a shared example"
    
  end

  context "when in a context" do
    
    it "should pass" do
      passing_spec
    end

    it "should fail" do
      failing_spec
    end

    it "should error" do
      error!
    end

    it "should be pending" do
      pending
    end
    
  end

  context "outside context" do

    before :each do
      @outer = []
    end

    context "nested context" do
      
      before :each do
        @outer << "test"
        @inner = 1
      end
      
      
      it "should have access to outer" do
        @outer.should == ["test"]
      end

      it "should have access to inner" do
        @inner.should == 1
      end
      
    end

    it "should still have access to outer" do
      @outer.should == []
    end

    it "should not have access to inner" do
      defined?(@inner).should_not be_true
    end

  end

  describe "mocks" do
    it "should raise a MockExpectationError" do
      @it = Object.new
      @it.should_receive(:poke!)
    end
  end
  
end
