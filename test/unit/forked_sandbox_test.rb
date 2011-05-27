require 'test_helper'
require 'timeout'

class ForkedSandboxTest < Test::Unit::TestCase
  include Tack
  
  should 'return even if data to marshall is very large' do
    sandbox = ForkedSandbox.new
    begin
      timeout(5) do
        sandbox.run do 
          random_strings = Array.new(1000){ (Array.new(25) {rand(10)}).join('')}
        end
      end
    rescue Timeout::Error => e
      flunk "Test timed out while returning data"
    end
  end

  should 'return value from block' do
    sandbox = ForkedSandbox.new
    result = sandbox.run do
      'x'
    end
    assert_equal 'x', result
  end

end
