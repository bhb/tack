require 'test_helper'

class RSpecTest < Test::Unit::TestCase

  should "grab all specs" do
    
    within_construct(false) do |c|
      c.file 'fake_spec.rb' do
        <<-EOS
        describe String do
          
          specify "something" do
          end

          it "should do something" do
          end

        end
EOS
      end
      set = Tack::TestSet.new(c)
      tests = set.tests_for(c+'fake_spec.rb')
      assert_equal 2, tests.length
      assert_equal [(c+"fake_spec.rb").to_s, "something"], tests.sort.last
      assert_equal [(c+"fake_spec.rb").to_s,"should do something"], tests.sort.first
    end    

  end

  should "find specs that match substring" do
    within_construct(false) do |c|
      c.file 'fake_spec.rb' do
        <<-EOS
        describe String do
          
          specify "something" do
          end

          it "does nothing" do
          end

        end
EOS
      end
      set = Tack::TestSet.new(c)
      tests = set.tests_for(c+'fake_spec.rb', "some")
      assert_equal 1, tests.length
      assert_equal [(c+'fake_spec.rb').to_s, "something"], tests.sort.first
    end
  end

  should "find specs that match regular expression" do
    within_construct(false) do |c|
      c.file 'fake_spec.rb' do
        <<-EOS
        describe String do
          
          specify "something" do
          end

          it "does nothing" do
          end

        end
EOS
      end
      set = Tack::TestSet.new(c)
      tests = set.tests_for(c+'fake_spec.rb', /does/)
      assert_equal 1, tests.length
      assert_equal [(c+'fake_spec.rb').to_s, "does nothing"], tests.sort.first
    end
  end


  should "run failing spec" do
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

  should "run successful spec" do
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
