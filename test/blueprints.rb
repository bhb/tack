require 'machinist/object'
require 'sham'

Tack::Util::Test.blueprint do
  file 'foo.rb'
  contexts ['FooTest']
  description 'test1'
end

Tack::Util::TestFailure.blueprint do
  message 'FAKE FAILURE MESSAGE'
  backtrace []
end
