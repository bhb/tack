module Tack

  module Util
    
    class Test
      
      attr_accessor :file, :context, :description

      def initialize(*args)
        if(args.length == 1 && args.first.is_a?(Hash))
          opts = args.first
          @file = opts.fetch(:file) {''}
          @context = opts.fetch(:context) {[]}
          @description = opts.fetch(:description) {''}
        else
          @file, @context, @description = args
        end
      end

      def to_basics
        [file, context, description].map {|x| basics(x)}
      end

      def name
        "#{context.join(' ')} #{description}"
      end

    end

  end

end
