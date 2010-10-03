class Adder #comment

  def initialize(num)
    @num = num
  end

  def plus(other_num)
    @num + other_num
  end

  def foobar
    baz
  end

  def baz
    raise "problem"
  end
  

end
