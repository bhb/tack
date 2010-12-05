module Tack

  module Util
    
    class Test
      
      attr_accessor :path, :contexts, :description

      def initialize(*args)
        if args.length == 1
          if args.first.is_a?(Test)
            @path = args.first.path
            @contexts = args.first.contexts
            @description = args.first.description
          elsif args.first.is_a?(Hash)
            opts = args.first
            @path = opts.fetch(:path) {''}
            @contexts = opts.fetch(:contexts) {[]}
            @description = opts.fetch(:description) {''}
          elsif args.first.is_a?(Enumerable)
            @path, @contexts, @description = args.first
          end
        else
          @path, @contexts, @description = args
        end
      end

      def to_basics
        [path, contexts, description]
      end

      def name
        "#{contexts.join(' ')} #{description}"
      end

    end

  end

end
