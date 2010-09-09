require 'machinist/object'
require 'sham'

Tack::Util::Test.blueprint do
  file 'foo.rb'
  context ['FooTest']
  description 'test1'
end
