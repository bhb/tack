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
      results = { :passed => [],
        :failed => [],
        :pending => []}
      tests.each do |path, description|
        adapter = Adapters::Adapter.for(path)
        result = adapter.run(path, description)
        results[:passed] += result[:passed]
        results[:failed] += result[:failed]
        results[:pending] += result[:pending]
        # @handlers.reverse.inject(inner_app) { |a, e| e.call(a) }
        @handlers.reverse.each do |handler|
          handler.process(result)
        end
      end
      @handlers.reverse.each do |handler|
        handler.finish(results)
      end
      results
    end

    def use(middleware, *args, &block)
      @handlers << middleware.new
    end

  end

end
