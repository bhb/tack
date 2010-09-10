module Tack

  module Util
    
    class Test
      
      attr_accessor :file, :context, :description

      def initialize(opts={})
        @file = opts.fetch(:file) {''}
        @contexts = opts.fetch(:contexts) {[]}
        @description = opts.fetch(:description) {''}
      end

      def to_basics
        [file, context, description].map {|x| basics(x)}
      end

    end

  end

end
