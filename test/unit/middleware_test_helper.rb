module MiddlewareTestHelper
  include TestHelpers

  def self.included(base)
    base.extend(ClassMethods)
  end

  def middleware_class
    raise NotImplementedError
  end

  module ClassMethods
    
    def should_behave_like_middleware

      context "#run_suites" do

        should "define #run_suite method" do
          assert middleware_class.new(nil).respond_to?(:run_suite)
          assert_equal 1, middleware_class.new(nil).method(:run_suite).arity
        end

        should "call #run_suite on inner middleware" do
          fake_middleware = stub_everything
          middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
          tests = [Tack::Util::Test.make.to_basics]
          fake_middleware.expects(:run_suite).with(tests).returns(results_for(tests))
          middleware.run_suite(tests)
        end
      end

      context "#run_test" do

        should "define #run_test method" do
          assert middleware_class.new(nil).respond_to?(:run_test)
          assert_equal 1, middleware_class.new(nil).method(:run_test).arity
        end

        should "call #run_test on inner middleware" do
          fake_middleware = stub_everything
          middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
          test = Tack::Util::Test.make.to_basics
          result = Tack::Result.for_test(test).to_basics
          fake_middleware.expects(:run_test).with(test).returns(result)
          middleware.run_test(test)
        end

      end
      
    end
  end
end
