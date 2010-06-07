require 'test_helper'

class TestUnitTest < Test::Unit::TestCase

  def remove_test_class_definition(klass_name)
    Object.send(:remove_const, klass_name)
  end

  def with_test_class(args)
    body = args.fetch(:body)
    class_name = args.fetch(:class_name) { :FakeTest } 
    within_construct(false) do |c|
      begin
        file = c.file 'fake_test.rb' do
          <<-EOS
          require 'test/unit'
    
          class #{class_name} < Test::Unit::TestCase
          
            #{body}

          end
EOS
        end
        path = c + file.to_s
        yield file.to_s, path
      ensure
        remove_test_class_definition(class_name)
      end
    end
  end

  should "flunk" do
    flunk
  end

  should "grab all tests" do
    body =<<-EOS
    def test_one
    end
      
    def test_two
    end
    EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, "test_one"], tests.sort.first
      assert_equal [file_name, "test_two"], tests.sort.last
    end
  end

  should "find tests that match substring" do
    body=<<-EOS
    def test_one
    end
    def test_two
    end
    EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, "two")
      assert_equal 1, tests.length
      assert_equal [file_name, "test_two"], tests.sort.first
    end
  end

  should "find tests that match regular expression" do
    body=<<-EOS
    def test_one
    end
    def test_two
    end
    EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path, /two/)
      assert_equal 1, tests.length
      assert_equal [file_name, "test_two"], tests.sort.first
    end
  end

  should "run failing test" do
    body =<<-EOS
    def test_append_length
      assert_equal ("ab".length - "cd".length), ("ab"+"cd").length
    end
EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)

      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length
      assert_equal "test_append_length", results[:failed].first[:description]
    end
  end

  should "run successful test" do
    body =<<-EOS
    def test_append_length
      assert_equal ("ab".length + "cd".length), ("ab"+"cd").length
    end
EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new(path.parent)
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      assert_equal 1, results[:passed].length
      assert_equal 0, results[:failed].length
      assert_equal "test_append_length", results[:passed].first[:description]
    end    
  end

end
