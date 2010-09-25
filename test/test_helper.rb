require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'construct'
require 'ruby-debug'
require 'mocha'


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'tack'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")

autoload :FormatterTestHelper, 'unit/formatters/formatter_test_helper'
autoload :MiddlewareTestHelper, 'unit/middleware_test_helper'

module TestHelpers
  include Construct::Helpers
  
  def deep_clone(obj)
    Marshal.load( Marshal.dump(obj))
  end

  def results_for(tests)
    Tack::ResultSet.new(:passed => tests.map {|test| Tack::Result.for_test(tests).to_basics}).to_basics
  end
  
  def in_rspec(args)
    body = args.fetch(:body)
    describe = args.fetch(:describe) { String }
    within_construct(false) do |c|
      file_name = 'fake_spec.rb'
      c.file file_name do
        <<-EOS
        describe #{describe} do
      
        #{body}

        end
        EOS
      end
      path = c+file_name.to_s
      yield path
    end
  end

  def remove_test_class_definition(class_name)
    top = class_name.to_s.split('::').first
    Object.send(:remove_const, top) if Object.const_defined?(top)
  end

  def with_test_class(args)
    body = args.fetch(:body)
    shoulda = args.fetch(:shoulda)  {false}
    class_name = args.fetch(:class_name) { :FakeTest } 
    within_construct(false) do |c|
      begin
        file = c.file 'fake_test.rb' do
          <<-EOS
          #{"require 'shoulda'" if shoulda}
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

  def in_shoulda(args, &block)
    with_test_class(args.merge(:shoulda => true), &block)
  end

  def capture_io
    require 'stringio'
    
    orig_stdout, orig_stderr = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr = captured_stdout, captured_stderr
    
    yield
    
    return captured_stdout.string, captured_stderr.string
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end

end

class Test::Unit::TestCase
  # I'm trying not to pollute TestCase since Shoulda adds to it
  # and it caused weird interactions in some of the tests.
end

