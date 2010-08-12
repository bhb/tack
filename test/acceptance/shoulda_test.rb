require 'test_helper'

class ShouldaTest < Test::Unit::TestCase
  include TestHelpers

  should "run tests that match substring" do
    body = <<-EOS
    should "do something" do
    end

    should "do nothing" do
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path, "some")
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.length
    end
  end

  should "run tests that match regular expression" do
    body = <<-EOS
    should "do something" do
    end

    should "do nothing" do
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path, /nothing/)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.length
    end
  end

  should "run tests that are in context which matches regexp" do
    body = <<-EOS
    context "sometimes" do
      context "in some cases" do

        should "do something" do
        end

        should "do another thing" do
        end

      end
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path, /cases/)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 2, result_set.length
    end
  end

  should "run failing test" do
    body = <<-EOS
    should "append length is sum of component string lengths" do
      assert_equal ("ab"+"cd").length, ("ab".length - "cd".length)
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.failed.length
    end
  end

  should "run pending test" do
    body = <<-EOS
    should_eventually "append length is sum of component string lengths" do
      assert_equal ("ab"+"cd").length, ("ab".length - "cd".length)
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.pending.length
    end
  end

  should "run test that raises error" do
    body = <<-EOS
    should "append length is sum of component string lengths" do
      raise "failing!"
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.failed.length
    end
  end

  should "run successful test" do
    body = <<-EOS
    should "append length is sum of component string lengths" do
      assert_equal ("ab"+"cd").length, ("ab".length + "cd".length)
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.passed.length
    end
  end

  context "in a context" do
    
    should "run successful test" do
      body = <<-EOS
        context "in all cases" do
          should "append length is sum of component string lengths" do
            assert_equal ("ab"+"cd").length, ("ab".length + "cd".length)
          end
        end
      EOS
      with_test_class :body => body do |file_name, path|
        raw_results = Tack::Runner.run_tests(path.parent, path)
        result_set = Tack::ResultSet.new(raw_results)
        assert_equal 1, result_set.passed.length
      end
    end

  end

  context "two testcases in the same file" do
    
    should "run all tests" do
      code =<<-EOS
      class FooTest < Test::Unit::TestCase
        should "do something" do
        end
      end

      class BarTest < Test::Unit::TestCase
        should "do something else" do
        end
      end
EOS
      within_construct(false) do |c|
        file = c.file 'fake_test.rb', code
        raw_results = Tack::Runner.run_tests(file.parent, file)
        result_set = Tack::ResultSet.new(raw_results)
        assert_equal 2, result_set.length
      end
    end

  end

end
