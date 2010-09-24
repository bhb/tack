require 'test_helper'
require 'stringio'

class CommandLineTest < Test::Unit::TestCase
  include Construct::Helpers

  should "report missing file" do
    stderr = StringIO.new
    assert_nothing_raised do 
      ::Tack::CommandLine.run(['missing_file.rb'], 
                                       :stdout => stub_everything, 
                                       :stderr => stderr)
    end
    stderr.rewind
    stderr = stderr.read
    assert_match /No such file or directory/, stderr
    assert_match /Some test files were missing. Quitting./, stderr
  end

  should "should exit 1 if any files are missing" do
    status = nil
    within_construct(false) do |c|
      c.file 'test.rb'
      status = ::Tack::CommandLine.run(['missing_file.rb', 'test.rb'],
                                       :stdout => stub_everything,
                                       :stderr => stub_everything)
    end
    assert_equal 1, status
  end

end
