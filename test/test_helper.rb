require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'construct'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tack'

module TestHelpers
  include Construct::Helpers

  def remove_test_class_definition(class_name)
    Object.send(:remove_const, class_name) if Object.const_defined?(class_name)
  end

  def with_test_class(args)
    body = args.fetch(:body)
    class_name = args.fetch(:class_name) { :FakeTest } 
    within_construct(false) do |c|
      begin
        file = c.file 'fake_test.rb' do
          <<-EOS
          require 'test/unit'
    
          class #{class_name} < Test::Unit::TestCase
          
            #{body}

          end
EOS
        end
        path = c + file.to_s
        yield file.to_s, path
      ensure
        remove_test_class_definition(class_name)
      end
    end
  end

end

class Test::Unit::TestCase
  # I'm trying not to pollute TestCase since Shoulda adds to it
  # and it caused weird interactions in some of the tests.
end
