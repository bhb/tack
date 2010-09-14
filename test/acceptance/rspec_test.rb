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
      assert_equal 1, result_set.length
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
      assert_equal 1, result_set.length
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
      assert_equal 1, result_set.length
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
        assert_equal 1, result_set.length
        assert_equal 1, result_set.passed.length
      end
    end

  end

 context "two describe blocks in the same file" do
    
    should "run all tests" do
      code =<<-EOS
      describe :Foo do
        specify "do something" do
        end
      end

      describe :Bar do
        specify "do something else" do
        end
      end
EOS
      within_construct(false) do |c|
        file = c.file 'fake_spec.rb', code
        raw_results = Tack::Runner.run_tests(file.parent, file)
        result_set = Tack::ResultSet.new(raw_results)
        assert_equal 2, result_set.length
      end
    end

  end

  context "with before/after blocks" do

    # "before :all" and "after :all" blocks are NOT supported, in the
    # sense that they will run, but will be run multiple times.
    # It's possible to make them work, but pretty hard until a better
    # RSpec adapter is written. Considerations:
    #   1. The RSpec adapter must be stateful to remember which contexts
    #      have been started so it doesn't run "before :all" blocks again
    #   2. All instance variables created/altered in "before/after :all" blocks
    #      must be availalbe in before :each blocks and actual specs
    #   3. A strategy for running "after :all" blocks must be created. When is the 
    #      right time to do this? Will the adapter need to know the full set of
    #      tests ahead of time? Will it run "after :all" blocks when the context 
    #      changes?
    #  Since, in the vast majority of cases, running the "before :all" and "after 
    # :all" blocks multiple times won't break a suite (although it may slow it down
    # and *could* potentially break it), I'm punting for now. Hopefully someone who
    # understands RSpec better than I can write an adapter that works.
    should "run all blocks and return correct results" do
      within_construct(false) do |c|
        tripwire = c.file 'tripwire'
        body =<<-EOS
        before :each do
          File.open('#{tripwire}','a') { |f| f << "In before :each\n"}
        end
        it 'should do something' do
        end
        it 'should do something else' do
        end
        after :each do
          File.open('#{tripwire}','a') {|f| f << "In after :each\n"}
        end
        EOS
        in_rspec :body => body do |path|
          raw_results = Tack::Runner.run_tests(path.parent, path)
          result_set = Tack::ResultSet.new(raw_results)
          assert_equal 2, result_set.length
          actual = File.readlines(tripwire)
          expected = ["In before :each\n",
                      "In after :each\n",
                      "In before :each\n",
                      "In after :each\n"]
          assert_equal expected, actual
        end
      end
    end
  end

end
