require 'test_helper'
require 'stringio'

class CommandLineTest < Test::Unit::TestCase
  include Construct::Helpers

  def command_line(files, opts = {})
    defaults = {:stdout => stub_everything,
                :stderr => stub_everything
    }
    ::Tack::CommandLine.run(files, defaults.merge(opts))
  end
  
  should "report missing file" do
    stderr = StringIO.new
    assert_nothing_raised do 
      command_line(['missing_file'], :stderr => stderr)
    end
    stderr.rewind
    stderr = stderr.read
    assert_match /No such file or directory/, stderr
    assert_match /Some test files were missing. Quitting./, stderr
  end

  should "exit 1 if any files are missing" do
    status = nil
    within_construct(false) do |c|
      testrb = c.file 'test.rb'
      assert File.exists?(testrb)
      status = command_line(['missing_file.rb', testrb])
    end
    assert_equal 1, status
  end

  should "give error and exit 1 if adapter cannot be found" do
    within_construct(false) do |c|
      testrb = c.file 'foobar.rb'
      assert File.exists?(testrb)
      stderr = StringIO.new
      status = command_line([testrb], :stderr => stderr)
      stderr.rewind
      assert_match /Cannot determine a test adapter for file .*\/foobar.rb/, stderr.read
      assert_equal 1, status
    end
  end

end
