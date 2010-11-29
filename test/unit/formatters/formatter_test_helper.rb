# Formatters should not change the requested tests or the results
module FormatterTestHelper
  include TestHelpers
  include Tack::Formatters

  def self.included(base)
    base.extend(ClassMethods)
  end

  def middleware_class
    raise NotImplementedError
  end

  module ClassMethods
    
    def should_behave_like_formatter

      context "#run_suites" do

        should "not alter results" do
          fake_middleware = stub_everything
          middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
          tests = [Tack::Util::Test.make.to_basics]
          expected_results = results_for(tests)
          fake_middleware.stubs(:run_suite).returns(expected_results)
          assert_equal expected_results, middleware.run_suite(tests)
        end
        
      end

      context "#run_test" do

        should "not alter result" do
          fake_middleware = stub_everything
          middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
          test = Tack::Util::Test.make.to_basics
          expected_result = Tack::Result.for_test(test).to_basics
          fake_middleware.stubs(:run_test).returns(expected_result)
          assert_equal expected_result, middleware.run_test(test)
        end
        
      end

    end

  end
  
end
