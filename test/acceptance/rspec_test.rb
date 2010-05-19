require 'test_helper'

class RSpecTest < Test::Unit::TestCase

  should "run RSpec failing spec" do
    within_construct(false) do |c|
      c.file 'fake_spec.rb' do
        <<-EOS
        describe String do
          
          specify "append length is sum of component string lengths" do
             ("ab"+"cd").length.should == ("ab".length - "cd".length)
          end

        end
EOS
      end
      set = Tack::TestSet.new(c)
      tests = set.tests_for(c+'fake_spec.rb')
      runner = Tack::Runner.new(c)
      results = runner.run(tests)
      
      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length
      assert_equal "append length is sum of component string lengths", results[:failed].first[:description]
    end    
  end

  should "run RSpec successful spec" do
    within_construct(false) do |c|
      c.file 'fake_spec.rb' do
        <<-EOS
        describe String do
          
          specify "append length is sum of component string lengths" do
             ("ab"+"cd").length.should == ("ab".length + "cd".length)
          end

        end
EOS
      end
      set = Tack::TestSet.new(c)
      tests = set.tests_for(c+'fake_spec.rb')
      runner = Tack::Runner.new(c)
      results = runner.run(tests)
      
      assert_equal 1, results[:passed].length
      assert_equal 0, results[:failed].length
      assert_equal "append length is sum of component string lengths", results[:passed].first[:description]
    end
  end

end
