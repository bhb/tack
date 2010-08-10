# Formatters should not change the requested tests or the results
module FormatterTestHelper
  
  def should_behave_like_formatter
    context "run_suites" do

      should "define #run_suite method" do
        assert middleware_class.new(nil).respond_to?(:run_suite)
        assert_equal 1, middleware_class.new(nil).method(:run_suite).arity
      end

      should "call #run_suite on inner middleware" do
        fake_middleware = stub_everything
        middleware = middleware_class.new(fake_middleware, :output => StringIO.new)
        tests = [build_test]
        fake_middleware.expects(:run_suite).with(tests).returns(results_for(tests))
        middleware.run_suite(tests)
      end
      
    end

    context "run_test" do

      should "define #run_test method" do
        assert middleware_class.new(nil).respond_to?(:run_test)
        assert_equal 3, middleware_class.new(nil).method(:run_test).arity
      end

      should "call #run_test on inner middleware" do
        fake_middleware = stub_everything
        middleware = middleware_class.new(fake_middleware)
        test = build_test
        fake_middleware.expects(:run_test).with(*test).returns(Tack::Result.for_test(test))
        middleware.run_test(*test)
      end
      
    end

  end
  
end
