require 'test_helper'

class AdapterViewerTest < Test::Unit::TestCase
  include Tack::Middleware
  include TestHelpers
  
  SHOULDA_FILE =<<-EOS
  require 'shoulda'
  class FooTest < Test::Unit::TestCase

    should "do something" do
    end

  end
  EOS

  TEST_UNIT_FILE =<<-EOS
  require 'test/unit'
  class FooTest < Test::Unit::TestCase

    def test_something
    end

  end
  EOS

  RSPEC_FILE =<<-EOS
  require 'spec'
  class Foo; end;
  describe Foo do

    specify "something" do
    end

  end
  EOS

  context "when all files use the same adapter" do
    
    should "report Shoulda adapter" do
      within_construct(false) do |c|
        c.directory 'test' do |d|
          d.file 'foo_test.rb', SHOULDA_FILE
          d.file 'bar_test.rb', SHOULDA_FILE
        end
        assert_output_matches /All files in directory .*\/?test use .*ShouldaAdapter/ do |output|
          middleware = AdapterViewer.new(nil, :output => output)
          middleware.run_suite([[c+'test/foo_test.rb', nil, nil],
                                [c+'test/bar_test.rb', nil, nil]])
        end
      end
    end

    should "report RSpec adapter" do
      within_construct(false) do |c|
        c.directory 'spec' do |d|
          d.file 'foo_spec.rb', RSPEC_FILE
          d.file 'bar_spec.rb', RSPEC_FILE
        end
        assert_output_matches /All files in directory .*\/?spec use .*RSpecAdapter/ do |output|
          middleware = AdapterViewer.new(nil, :output => output)
          middleware.run_suite([[c+'spec/foo_spec.rb', nil, nil],
                                [c+'spec/bar_spec.rb', nil, nil]])
        end
      end
    end

    should "report Test::Unit adapter" do
      within_construct(false) do |c|
        c.directory 'test' do |d|
          d.file 'foo_test.rb', TEST_UNIT_FILE
          d.file 'bar_test.rb', TEST_UNIT_FILE
        end
        assert_output_matches /All files in directory .*\/?test use .*TestUnitAdapter/ do |output|
          middleware = AdapterViewer.new(nil, :output => output)
          middleware.run_suite([[c+'test/foo_test.rb', nil, nil],
                                [c+'test/bar_test.rb', nil, nil]])
        end
      end
    end

  end

  context "when all files in nested directories use same adapter" do

    should "report that adapter for top-level directory" do
      within_construct(false) do |c|
        c.directory 'test' do |test|
          test.directory 'unit' do |d|
            d.file 'foo_test.rb', TEST_UNIT_FILE
            d.file 'bar_test.rb', TEST_UNIT_FILE
          end
          test.directory 'functional' do |d|
            d.file 'foo_test.rb', TEST_UNIT_FILE
            d.file 'bar_test.rb', TEST_UNIT_FILE
          end
        end
        assert_output_matches /All files in directory .*\/?test use .*TestUnitAdapter/ do |output|
          middleware = AdapterViewer.new(nil, :output => output)
          middleware.run_suite([[c+'test/unit/foo_test.rb', nil, nil],
                                [c+'test/unit/bar_test.rb', nil, nil],
                                [c+'test/functional/foo_test.rb', nil, nil],
                                [c+'test/functional/bar_test.rb', nil, nil]])


        end
      end
    end

  end

  context "when all files in different directories use different adapters" do
    
    should "report respective adapters" do
      within_construct(false) do |c|
        c.directory 'test' do |d|
          d.file 'foo_test.rb', TEST_UNIT_FILE
        end
        c.directory 'spec' do |d|
          d.file 'bar_spec.rb', RSPEC_FILE
        end
        output = StringIO.new
        middleware = AdapterViewer.new(nil, :output => output)
        middleware.run_suite([[c+'test/foo_test.rb', nil, nil],
                              [c+'spec/bar_spec.rb', nil, nil]])
        assert_match /All files in directory .*\/?test use .*TestUnitAdapter/, output.string
        assert_match /All files in directory .*\/?spec use .*RSpecAdapter/, output.string
      end
    end

  end

  context "when files in same director use different adapters" do

    should "report adapters for each file" do
      within_construct(false) do |c|
        c.directory 'test' do |d|
          d.file 'foo_test.rb', SHOULDA_FILE
          d.file 'bar_test.rb', TEST_UNIT_FILE
          d.file 'baz_spec.rb', RSPEC_FILE
        end
        output = StringIO.new
        middleware = AdapterViewer.new(nil, :output => output)
        middleware.run_suite([[c+'test/foo_test.rb', nil, nil],
                              [c+'test/bar_test.rb', nil, nil],
                              [c+'test/baz_spec.rb', nil, nil]])
        assert_match %r{test/foo_test\.rb uses .*ShouldaAdapter}, output.string
        assert_match %r{test/bar_test\.rb uses .*TestUnitAdapter}, output.string
        assert_match %r{test/baz_spec\.rb uses .*RSpecAdapter}, output.string
      end
    end
    
  end

end
