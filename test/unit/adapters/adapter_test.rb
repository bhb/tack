require 'test_helper'

class AdapterTest < Test::Unit::TestCase
  include TestHelpers
  include Tack::Adapters

  should "return Test::Unit adapter for files starting in 'test'" do
    within_construct(false) do |c|
      file = c.file 'test_something.rb'
      assert_kind_of TestUnitAdapter, Adapter.for(file)
    end
  end

  should "return Test::Unit adapter for files ending in 'test.rb'" do
    within_construct(false) do |c|
      file = c.file 'myclass_test.rb'
      assert_kind_of TestUnitAdapter, Adapter.for(file)
    end
  end

  should "return RSpec adapter for files ending in 'spec.rb'" do
    within_construct(false) do |c|
      file = c.file 'myclass_spec.rb'
      assert_kind_of RSpecAdapter, Adapter.for(file)
    end
  end

  context "when combining Shoulda and Test::Unit" do

    should "return the correct adapters" do
      body =<<-EOS
        should "do something" do
        end
      EOS
      with_test_class :body => body, :shoulda => true, :class_name => :FooTest do |foo_file, foo_path|
        assert_kind_of ShouldaAdapter, Adapter.for(foo_path)
      end
      body =<<-EOS
      def test_one
      end
      EOS
      with_test_class :body => body, :class_name => :BarTest do |bar_file, bar_path|
        assert_kind_of TestUnitAdapter, Adapter.for(bar_path)
      end
    end
    
  end

end
