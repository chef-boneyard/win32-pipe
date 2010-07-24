##########################################################################
# test_win32_pipe_server.rb
#
# Test suite for the Pipe::Server class. This test suite should be run
# as part of the 'rake test' task.
##########################################################################
require 'test/unit'
require 'win32/pipe'
include Win32

class TC_Win32_Pipe_Server < Test::Unit::TestCase
   def setup
      @pipe = nil
   end

   def test_constructor_basic
      assert_respond_to(Pipe::Server, :new)
      assert_nothing_raised{ @pipe = Pipe::Server.new('foo') }
   end

   def test_connect
      assert_nothing_raised{ @pipe = Pipe::Server.new('foo') }
      assert_respond_to(@pipe, :connect)
   end

   def test_constructor_expected_errors
      assert_raise(ArgumentError){ Pipe::Server.new }
      assert_raise(TypeError){ Pipe::Server.new(1) }
   end

   def teardown
      @pipe = nil
   end
end
