require 'test_helper'
require 'fileutils'
require 'tack/middleware/parallel'

class ParallelTest < Test::Unit::TestCase
  include MiddlewareTestHelper
  include Tack::Middleware

  def middleware_class
    Parallel
  end

  should_implement_middleware_api
  should_not_modify_results

  class FakeAdapter
    include Construct::Helpers

    attr_accessor :count
    
    def initialize
      self.count = 0
    end
    
    def tests_for(path)
      [
       ["foo_test.rb", ["Fake"], "test something"], 
       ["foo_test.rb", ["Fake"], "test something else"]
      ]
    end

    def run_suite(tests)
      result_set = Tack::Util::ResultSet.new
      filename = 'tripwire.txt'
      tests.each do |test|
        if File.exists?(filename)
          result_set.fail(test, {})
        else
          FileUtils.touch(filename)
          sleep(0.1)
          result_set.pass(test)
        end
      end

      basics(result_set)
    ensure
      File.delete(filename) if File.exists?(filename)
    end
    
  end

  should "re-run tests that fail" do
    adapter = FakeAdapter.new
    assert_output_matches(/Rerunning \d+ tests/) do |output|
      middleware = Tack::Middleware::Parallel.new(adapter, :output => output, :processes => 2)
      tests = adapter.tests_for('')
      results = middleware.run_suite(tests)
      result_set = Tack::Util::ResultSet.new(results)
      assert_equal 0, result_set.failed.length
      assert_equal 2, result_set.passed.length
    end
  end
  
end
