##########################################################################
# test_win32_pipe_client.rb
#
# Test suite for the Pipe::Client class. This test suite should be run
# as part of the 'rake test' task.
##########################################################################
require 'test/unit'
require 'win32/pipe'

class TC_Win32_Pipe_Client < Test::Unit::TestCase
  def setup
    @server = Win32::Pipe::Server.new('test')
    @pipe   = nil
    @name   = 'test'
    @pmode  = Win32::Pipe::PIPE_NOWAIT
    @omode  = Win32::Pipe::DEFAULT_OPEN_MODE
  end

  test "constructor basic functionality" do
    assert_respond_to(Win32::Pipe::Client, :new)
    assert_nothing_raised{ @pipe = Win32::Pipe::Client.new(@name) }
  end

  test "constructor accepts an optional pipe mode" do
    assert_nothing_raised{ @pipe = Win32::Pipe::Client.new(@name, @pmode) }
  end

  test "constructor accepts an optional open mode" do
    assert_nothing_raised{ @pipe = Win32::Pipe::Client.new(@name, @pmode, @omode) }
  end

  test "constructor requires a pipe name" do
    assert_raise(ArgumentError){ Win32::Pipe::Client.new }
  end

  test "pipe name must be a string" do
    assert_raise(TypeError){ Win32::Pipe::Client.new(1) }
  end

  test "an error is raised if the named pipe cannot be found" do
    assert_raise(Win32::Pipe::Error){ Win32::Pipe::Client.new('bogus') }
  end

  def teardown
    if @pipe
      @pipe.disconnect
      @pipe.close
    end

    if @server
      @server.disconnect
      @server.close
    end

    @pmode  = nil
    @omode  = nil
    @pipe   = nil
    @server = nil
  end
end
