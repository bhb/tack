module Tack

  class Runner
    
    def initialize(args)
      if(args.is_a?(Hash))
        @root_dir = args.fetch(:root)
      else
        @root_dir = args
      end
      @handlers = []
      yield self if block_given?
    end

    def run(tests)
      to_app if @start_app.nil?
      @start_app.run_suite(tests)
    end

    def run_suite(tests)
      results = { :passed => [],
        :failed => [],
        :pending => []}
      tests.each do |path, context, description|
        result = @start_app.run_test(path, context, description)
        results[:passed] += result[:passed]
        results[:failed] += result[:failed]
        results[:pending] += result[:pending]
      end
      results
    end

    def run_test(path, context, description)
      adapter = Adapters::Adapter.for(path)
      adapter.run(path, context, description)
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
