require 'test_helper'

# class MiniTestShimTest < Test::Unit::TestCase
#   include TestHelpers

#   should_eventually "run tests that match substring" do
#     body=<<-EOS
#     def test_one
#     end
#     def test_two
#     end
#     EOS
#     with_mini_test_shim_class(:body => body, :class_name => :FakeTest) do |file_name, path|
#       raw_results = Tack::Runner.run_tests(path.parent, path, "two")
#       result_set = Tack::Util::ResultSet.new(raw_results)
#       assert_equal 1, result_set.length
#     end
#   end

#   should_eventually "run tests that match regular expression" do
#     body=<<-EOS
#     def test_one
#     end
#     def test_two
#     end
#     EOS
#     with_mini_test_shim_class(:body => body, :class_name => :FakeTest) do |file_name, path|
#       raw_results = Tack::Runner.run_tests(path.parent, path, /two/)
#       result_set = Tack::Util::ResultSet.new(raw_results)
#       assert_equal 1, result_set.length
#     end
#   end

#   should_eventually "run failing test" do
#     body =<<-EOS
#     def test_append_length
#       assert_equal ("ab".length - "cd".length), ("ab"+"cd").length
#     end
# EOS
#     with_mini_test_shim_class(:body => body) do |file_name, path|
#       raw_results = Tack::Runner.run_tests(path.parent, path)
#       result_set = Tack::Util::ResultSet.new(raw_results)
#       assert_equal 1, result_set.length
#       assert_equal 1, result_set.failed.length
#     end
#   end

#   should_eventually "run test with error" do
#     body =<<-EOS
#     def test_append_length
#       raise "failing!"
#     end
# EOS
#     with_mini_test_shim_class(:body => body) do |file_name, path|
#       raw_results = Tack::Runner.run_tests(path.parent, path)
#       result_set = Tack::Util::ResultSet.new(raw_results)
#       assert_equal 1, result_set.length
#       assert_equal 1, result_set.failed.length
#     end
#   end

#   should_eventually "run successful test" do
#     body =<<-EOS
#     def test_append_length
#       assert_equal ("ab".length + "cd".length), ("ab"+"cd").length
#     end
# EOS
#     with_mini_test_shim_class(:body => body) do |file_name, path|
#       raw_results = Tack::Runner.run_tests(path.parent, path)
#       result_set = Tack::Util::ResultSet.new(raw_results)
#       assert_equal 1, result_set.length
#       assert_equal 1, result_set.passed.length
#     end
#   end

#   context "two testcases in the same file" do
    
#     should_eventually "run all tests" do
#       code =<<-EOS
#       require 'test/unit'
#       class TestCase1 < Test::Unit::TestCase
#         def test_one
#         end
#       end

#       class TestCase2 < Test::Unit::TestCase
#         def test_two
#         end
#       end
# EOS
#       within_construct(false) do |c|
#         file = c.file 'fake_test.rb', code
#         raw_results = Tack::Runner.run_tests(file.parent, file)
#         result_set = Tack::Util::ResultSet.new(raw_results)
#         assert_equal 2, result_set.length
#       end
#     end

#     should_eventually "run tests defined in superclass" do
#       code =<<-EOS
#       require 'test/unit'
#       class BaseTest < Test::Unit::TestCase
#         def test_one
#         end
#       end

#       class DerivedTest < BaseTest
#         def test_two
#         end
#       end
# EOS
#       within_construct(false) do |c|
#         path = c.file 'fake_test.rb', code
#         raw_results = Tack::Runner.run_tests(path.parent, path, /DerivedTest/)
#         result_set = Tack::Util::ResultSet.new(raw_results)
#         assert_equal 2, result_set.length
#         assert_equal ['test_one', 'test_two'], result_set.passed.map {|result| result.test.last}.sort
#       end
#     end

#   end

# end


