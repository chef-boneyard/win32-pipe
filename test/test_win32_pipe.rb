##########################################################################
# test_win32_pipe.rb
#
# Test suite for the win32-pipe library. This test suite should be run
# via the 'rake test' task.
##########################################################################
require 'test-unit'
require 'test/unit'
require 'win32/pipe'
include Win32

class TC_Win32_Pipe < Test::Unit::TestCase
  def setup
    @pipe = Pipe.new('foo')
  end

  test "version is set to expected value" do
    assert_equal('0.3.0', Pipe::VERSION)
  end

  test "name method basic functionality" do
    assert_respond_to(@pipe, :name)
    assert_nothing_raised{ @pipe.name }
    assert_kind_of(String, @pipe.name)
  end

  test "name returns expected string" do
    assert_equal("\\\\.\\pipe\\foo", @pipe.name)
  end

  test "mode method basic functionality" do
    assert_respond_to(@pipe, :pipe_mode)
    assert_nothing_raised{ @pipe.pipe_mode }
    assert_kind_of(Fixnum, @pipe.pipe_mode)
  end

  test "mode method returns expected value" do
    assert_equal(Pipe::DEFAULT_PIPE_MODE, @pipe.pipe_mode)
  end

  test "open_mode basic functionality" do
    assert_respond_to(@pipe, :open_mode)
    assert_nothing_raised{ @pipe.open_mode }
    assert_kind_of(Numeric, @pipe.open_mode)
  end

  test "open_mode returns the expected value" do
    assert_equal(Pipe::DEFAULT_OPEN_MODE, @pipe.open_mode)
  end

  test "buffer method basic functionality" do
    assert_respond_to(@pipe, :buffer)
    assert_nothing_raised{ @pipe.buffer }
  end

  test "size basic functionality" do
    assert_respond_to(@pipe, :size)
    assert_nothing_raised{ @pipe.size }
  end

  test "length is an alias for size" do
    assert_respond_to(@pipe, :length)
    assert_alias_method(@pipe, :length, :size)
  end

  test "pending method basic functionality" do
    assert_respond_to(@pipe, :pending?)
    assert_nothing_raised{ @pipe.pending? }
    assert_boolean(@pipe.pending?)
  end

  test "pending method defaults to false" do
    assert_false(@pipe.pending?)
  end

  test "asynchronous method basic functionality" do
    assert_respond_to(@pipe, :asynchronous?)
    assert_nothing_raised{ @pipe.asynchronous? }
    assert_boolean(@pipe.asynchronous?)
  end

  test "asynchronous method defaults to false" do
    assert_false(@pipe.asynchronous?)
  end

  test "read method basic functionality" do
    assert_respond_to(@pipe, :read)
  end

  test "read method raises an error if there's nothing to read" do
    assert_raises(SystemCallError){ @pipe.read }
  end

  test "transfered method basic functionality" do
    assert_respond_to(@pipe, :transferred)
    assert_nothing_raised{ @pipe.transferred }
  end

  test "wait method basic functionality" do
    assert_respond_to(@pipe, :wait)
  end

  test "wait method raises an error in blocking mode" do
    assert_raises(SystemCallError){ @pipe.wait }
  end

  test "write method basic functionality" do
    assert_respond_to(@pipe, :write)
  end

  test "write method requires one argument" do
    assert_raises(ArgumentError){ @pipe.write }
  end

  test "write method raises an error if there's nothing to write to" do
    assert_raises(SystemCallError){ @pipe.write("foo") }
  end

  test "disconnect method basic functionality" do
    assert_respond_to(@pipe, :disconnect)
    assert_nothing_raised{ @pipe.disconnect }
  end

  test "calling the disconnect method multiple times has no effect" do
    assert_nothing_raised{ @pipe.disconnect; @pipe.disconnect }
  end

  test "close method basic functionality" do
    assert_respond_to(@pipe, :close)
    assert_nothing_raised{ @pipe.close }
  end

  test "calling close multiple times has no effect" do
    assert_nothing_raised{ @pipe.close; @pipe.close }
  end

  test "pipe_mode constants" do
    assert_not_nil(Pipe::WAIT)
    assert_not_nil(Pipe::NOWAIT)
    assert_not_nil(Pipe::TYPE_BYTE)
    assert_not_nil(Pipe::TYPE_MESSAGE)
    assert_not_nil(Pipe::READMODE_BYTE)
    assert_not_nil(Pipe::READMODE_MESSAGE)
  end

  test "open_mode constants" do
    assert_not_nil(Pipe::ACCESS_DUPLEX)
    assert_not_nil(Pipe::ACCESS_INBOUND)
    assert_not_nil(Pipe::ACCESS_OUTBOUND)
    assert_not_nil(Pipe::FIRST_PIPE_INSTANCE)
    assert_not_nil(Pipe::WRITE_THROUGH)
    assert_not_nil(Pipe::OVERLAPPED)
  end

  test "other contants" do
    assert_not_nil(Pipe::INFINITE)
  end

  def teardown
    @pipe.close if @pipe
    @pipe = nil
  end
end
