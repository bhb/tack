module Tack

  module StableSort

    def stable_sort
      n = 0
      c = lambda { |x| n+= 1; [x, n]}
      if block_given?
        sort { |a, b|
          yield(c.call(a), c.call(b))        
        }
      else
        sort_by &c
      end
    end
    
  end

end
