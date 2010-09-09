module Tack

  module Util
    
    class Test
      
      attr_accessor :file, :context, :description

      def initialize(opts={})
        @file = opts.fetch(:file) {''}
        @contexts = opts.fetch(:contexts) {[]}
        @description = opts.fetch(:description) {''}
      end

      def to_primitives
        [file, context, description]
      end

    end

  end

end
