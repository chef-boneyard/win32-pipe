##########################################################################
# test_win32_pipe_client.rb
#
# Test suite for the Pipe::Client class. This test suite should be run
# as part of the 'rake test' task.
##########################################################################
require 'test/unit'
require 'win32/pipe'
include Win32

class TC_Win32_Pipe_Client < Test::Unit::TestCase
   def setup
      @pipe = nil
   end

   def test_constructor_basic
      assert_respond_to(Pipe::Client, :new)
   end

   def test_constructor_expected_errors
      assert_raise(ArgumentError){ Pipe::Client.new }
      assert_raise(TypeError){ Pipe::Client.new(1) }
   end

   def teardown
      @pipe = nil
   end
end
