module Tack

  class Runner

    def self.run_tests(root, path, pattern=TestPattern.new)
      test_set = TestSet.new
      tests = test_set.tests_for(path, pattern)
      
      runner = Runner.new(root)
      runner.run(tests)
    end

    def initialize(args)
      if(args.is_a?(Hash))
        @root_dir = args.fetch(:root)
      else
        @root_dir = args
      end
      @handlers = []
      @adapters = {}
      yield self if block_given?
    end

    def run(tests)
      to_app if @start_app.nil?
      @start_app.run_suite(tests)
    end

    def run_suite(tests)
      (@adapter ||= Adapters::Adapter.new(@start_app)).run_suite(tests)
    end

    # TODO - this class both builds the middleware chain 
    # and acts as a kind of wrapper around real adapters.
    # I think I should move some functionality around 
    # (make a real middleware that identifies the adapter on
    # the fly and have the builder be separate)
    def run_test(test)
      path, _, _ = test
      adapter = Adapters::Adapter.for(path)
      adapter.run_test(test)
    end

    def use(middleware, *args, &block)
      @handlers << lambda { |app|
        middleware.new(app, *args, &block) }
    end

    def to_app
      inner_app = self
      @start_app = @handlers.reverse.inject(inner_app) { |a, e| e.call(a) }
    end

  end

end
