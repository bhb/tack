module Tack

  class Shuffle
    include Middleware
    
    def run_suite(tests)
      puts "--> Shuffling tests"

      tests = shuffle(tests)
      @app.run_suite(tests) 
    end

    private

    def shuffle(array)
      array = array.dup
	    array.each_index do |i| 
	      j = rand(array.length-i) + i
	      array[j], array[i] = array[i], array[j]  
	    end
      array
	  end

  end

end
