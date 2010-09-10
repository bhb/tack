module Kernel
  
  def basics(obj)
    if obj.respond_to?(:to_basics)
      obj.to_basics
    else
      obj
    end
  end

end


