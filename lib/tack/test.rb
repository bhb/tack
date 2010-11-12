module Tack

  module Util
    
    class Test
      
      attr_accessor :file, :contexts, :description

      def initialize(*args)
        if args.length == 1
          if args.first.is_a?(Test)
            @file = args.first.file
            @contexts = args.first.contexts
            @description = args.first.description
          elsif args.first.is_a?(Hash)
            opts = args.first
            @file = opts.fetch(:file) {''}
            @contexts = opts.fetch(:contexts) {[]}
            @description = opts.fetch(:description) {''}
          elsif args.first.is_a?(Enumerable)
            @file, @contexts, @description = args.first
          end
        else
          @file, @contexts, @description = args
        end
      end

      def to_basics
        [file, contexts, description]
      end

      def name
        "#{contexts.join(' ')} #{description}"
      end

    end

  end

end
