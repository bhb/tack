type = ARGV.shift
filename = ARGV.shift

def rspec_test(num)
  <<-EOF
  specify 'spec number #{num}' do
  end
  EOF
end

def test_unit_test(num)
  <<-EOF
  def test_number_#{num}
  end
  EOF
end

def shoulda_test(num)
  <<-EOF
  should "do something (#{num})" do
  end
  EOF
end

test_unit_times = 1000
shoulda_times = 200
rspec_times = 200

case type.to_s
when 'test_unit'
  contents =<<-EOF
  require 'test/unit'  
  class SomeTest < Test::Unit::TestCase
  
    #{(0...test_unit_times).map{|i| test_unit_test(i)}.join("\n\n")}
   
  end
  EOF
when 'shoulda'
  contents =<<-EOF
  require 'shoulda'  
  class SomeTest < Test::Unit::TestCase
  
    #{(0...shoulda_times).map{|i| shoulda_test(i)}.join("\n\n")}
   
  end
  EOF
when 'rspec'
  contents =<<-EOF
  require 'spec'
  describe "something" do
    
    #{(0...rspec_times).map{|i| rspec_test(i)}.join("\n\n")}
    
  end
  EOF
else
  raise "Unknown test type '#{type}'"
end

File.open(filename, 'w') do |f|
  f << contents
end
