require 'test/unit'
require File.dirname(__FILE__)+'/adder'

class AdderTest < Test::Unit::TestCase
  include Math

  def test_foo
    raise "crash!"
  end

  def test_plus__num_is_zero
    assert_equal 7, Adder.new(0).plus(7)
  end

  def test_missing_method
    assert Adder.new(0).foobar
  end

  def test_plus__other_is_zero
    assert_equal 5, Adder.new(5).plus(0)
  end

  def test_plus__num_is_non_zero
    assert_equal 9, Adder.new(2).plus(7)
  end

  def test_plus__other_is_non_zero
    assert_equal 8, Adder.new(5).plus(3)
  end

  def test_plus__one_and_one
    assert_equal 2, Adder.new(1).plus(1)
  end  
  
  def test_plus__one_and_two
    assert_equal 2, Adder.new(1).plus(2)
  end

  def test_plus__one_and_three
    assert_equal 4, Adder.new(1).plus(3)
  end

  def test_plus__one_and_four
    assert_equal 5, Adder.new(1).plus(4)
  end

  def test_flunk
    x = true
    if(x)
      flunk
    else
      assert true
    end
  end 

end
