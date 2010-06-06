module Tack

  module Formatters

    class ProgressBar
      
      def process(result)
        result[:passed].each do
          print "."
        end
        result[:pending].each do
          print "P"
        end
        result[:failed].each do
          print "F"
        end
      end

      def finish(results)
        puts
      end
      
    end

  end

end
