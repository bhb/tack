require 'test_helper'

class ForkTest < Test::Unit::TestCase
  include MiddlewareTestHelper
  include Tack::Middleware

  should "return test result" do
    adapter = Tack::StubAdapter.new
    middleware = Fork.new(adapter, :output => StringIO.new)
    test = Tack::Util::Test.make.to_basics
    adapter.pass(test)
    expected_result = Tack::Result.for_test(test).to_basics
    assert_equal expected_result, middleware.run_test(test)
  end

  should "isolate side effects from each test" do
    body = <<-EOS
    def test_one
      @@var = 1
    end

    def test_two
     assert_nil defined?(@@var)
    end
    EOS
    with_test_class :class_name => 'FakeTest', :body => body do |_, path|
      tests = [[path.to_s, ['FakeTest'], 'test_one'],
               [path.to_s, 'FakeTest', 'test_two']]
      # check that forked, test state is isolated
      forked_app = Tack::Runner.new(path.parent) do |runner|
        runner.use Tack::Middleware::Fork, :output => StringIO.new
      end
      results = Tack::ResultSet.new(forked_app.run(tests))
      assert_equal 2, results.length
      assert_equal 0, results.failed.length

      # check that un-forked, test state is not isolated
      # this must be done after the forking test above
      app = Tack::Runner.new(path.parent).to_app
      results = Tack::ResultSet.new(app.run(tests))
      assert_equal 2, results.length
      assert_equal 1, results.failed.length
    end
  end

end
