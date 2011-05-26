module MiddlewareTestHelper
  include TestHelpers

  def self.included(base)
    base.extend(ClassMethods)
  end

  def middleware_class
    raise NotImplementedError
  end

  module ClassMethods

    def should_implement_middleware_api

      should "define #run_suite method" do
        middleware = middleware_class.new(nil, :output => StringIO.new)
        assert middleware.respond_to?(:run_suite)
        assert_equal 1, middleware.method(:run_suite).arity
      end

      should "define #run_test method" do
        middleware = middleware_class.new(nil, :output => StringIO.new)
        assert middleware.respond_to?(:run_test)
        assert_equal 1, middleware.method(:run_test).arity
      end
      
    end

    def should_not_modify_results
      
      should "not modify results from #run_suites" do
        fake_middleware = stub_everything
        middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
        tests = [Tack::Util::Test.make.to_basics]
        results = results_for(tests)
        fake_middleware.stubs(:run_suite).returns(results)
        assert_equal results, middleware.run_suite(tests)
      end

      should "not modify results from #run_test" do
        fake_middleware = stub_everything
        middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
        test = Tack::Util::Test.make.to_basics
        result = Tack::Util::Result.for_test(test).to_basics
        fake_middleware.stubs(:run_test).with(test).returns(result)
        assert_equal result, middleware.run_test(test)
      end

    end
    
    def should_behave_like_middleware
      
      should_implement_middleware_api

      context "#run_suites" do

        should "call #run_suite on inner middleware" do
          fake_middleware = stub_everything
          middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
          tests = [Tack::Util::Test.make.to_basics]
          fake_middleware.expects(:run_suite).with(tests).returns(results_for(tests))
          middleware.run_suite(tests)
        end
        
      end

      context "#run_test" do

        should "call #run_test on inner middleware" do
          fake_middleware = stub_everything
          middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
          test = Tack::Util::Test.make.to_basics
          result = Tack::Util::Result.for_test(test).to_basics
          fake_middleware.expects(:run_test).with(test).returns(result)
          middleware.run_test(test)
        end

      end
      
    end
  end
end
