require 'test_helper'

class RSpecTest < Test::Unit::TestCase
  include TestHelpers

  def with_rspec_context(args)
    body = args.fetch(:body)
    describe = args.fetch(:describe)
    within_construct(false) do |c|
      file_name = 'fake_spec.rb'
      c.file file_name do
        <<-EOS
        describe #{describe} do
      
        #{body}

        end
        EOS
      end
      path = c+file_name.to_s
      yield path
    end
  end

  should "grab all specs" do
    body = <<-EOS
    specify "something" do
    end

    it "should do something" do
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [path.to_s, "should do something"], tests.first
      assert_equal [path.to_s, "something"], tests.last
    end
  end

  should "find specs that match substring" do
    body = <<-EOS
    specify "something" do
    end

    it "does nothing" do
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, "some")
      assert_equal 1, tests.length
      assert_equal [path.to_s, "something"], tests.first
    end
  end

  should "find specs that match regular expression" do
    body = <<-EOS
    specify "something" do
    end

    it "does nothing" do
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, /does/)
      assert_equal 1, tests.length
      assert_equal [path.to_s, "does nothing"], tests.first
    end
  end

  should "run failing spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      ("ab"+"cd").length.should == ("ab".length - "cd".length)
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      
      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length
      result = results[:failed].first
      assert_equal "append length is sum of component string lengths", result[:description]
      assert_equal "expected: 0,\n     got: 4 (using ==)", result[:failure][:message]
      assert_kind_of Array, result[:failure][:backtrace]
    end
  end

  should "run spec that raises error" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      raise "failing!"
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      
      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length

      result = results[:failed].first
      assert_equal "append length is sum of component string lengths", result[:description]
      assert_match /was raised/, result[:failure][:message]
      assert_kind_of Array, result[:failure][:backtrace]
    end
  end

  should "run successful spec" do
    body = <<-EOS
    specify "append length is sum of component string lengths" do
      ("ab"+"cd").length.should == ("ab".length + "cd".length)
    end
    EOS
    with_rspec_context :describe => String, :body => body do |path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      
      assert_equal 1, results[:passed].length
      assert_equal 0, results[:failed].length
      assert_equal "append length is sum of component string lengths", results[:passed].first[:description]
    end
  end

end
