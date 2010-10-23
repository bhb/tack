type = ARGV.shift
filename = ARGV.shift

def rspec_test(num)
  <<-EOF
  specify 'spec number #{num}' do
  end
  EOF
end

case type.to_s
when 'rspec'

  contents =<<-EOF
  require 'spec'
  describe "something" do
    
    #{(0...200).map{|i| rspec_test(i)}.join("\n\n")}
    
  end
  EOF
else
  raise "Unknown test type '#{type}'"
end

File.open(filename, 'w') do |f|
  f << contents
end
