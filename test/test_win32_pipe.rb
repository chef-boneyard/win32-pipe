##########################################################################
# test_win32_pipe.rb
#
# Test suite for the win32-pipe library. This test suite should be run
# via the 'rake test' task.
##########################################################################
require 'test/unit'
require 'win32/pipe'
include Win32

class TC_Win32_Pipe < Test::Unit::TestCase
   def setup
      @pipe = Pipe.new('foo')
   end
   
   def test_version
      assert_equal('0.2.1', Pipe::VERSION)
   end

   def test_name
      assert_respond_to(@pipe, :name)
      assert_nothing_raised{ @pipe.name }
      assert_equal("\\\\.\\pipe\\foo", @pipe.name)
   end

   def test_pipe_mode
      assert_respond_to(@pipe, :pipe_mode)
      assert_nothing_raised{ @pipe.pipe_mode }
      assert_equal(Pipe::DEFAULT_PIPE_MODE, @pipe.pipe_mode)
   end

   def test_open_mode
      assert_respond_to(@pipe, :open_mode)
      assert_nothing_raised{ @pipe.open_mode }
      assert_equal(Pipe::DEFAULT_OPEN_MODE, @pipe.open_mode)
   end
   
   def test_buffer
      assert_respond_to(@pipe, :buffer)
      assert_nothing_raised{ @pipe.buffer }
   end
   
   def test_size
      assert_respond_to(@pipe, :size)
      assert_nothing_raised{ @pipe.size }
   end
   
   def test_length_alias
      assert_respond_to(@pipe, :length)
      assert_equal(true, @pipe.method(:length) == @pipe.method(:size))
   end
   
   def test_pending
      assert_respond_to(@pipe, :pending?)
      assert_nothing_raised{ @pipe.pending? }
      assert_equal(false, @pipe.pending?)
   end

   def test_asynchronous
      assert_respond_to(@pipe, :asynchronous?)
      assert_nothing_raised{ @pipe.asynchronous? }
      assert_equal(false, @pipe.asynchronous?)
   end
   
   def test_read
      assert_respond_to(@pipe, :read)
      assert_raises(Pipe::Error){ @pipe.read } # Nothing to read
   end
   
   def test_transferred
      assert_respond_to(@pipe, :transferred)
      assert_nothing_raised{ @pipe.transferred }
   end
   
   def test_wait
      assert_respond_to(@pipe, :wait)
      assert_raises(Pipe::Error){ @pipe.wait } # Can't wait in blocking mode
   end
   
   def test_write
      assert_respond_to(@pipe, :write)
      assert_raises(ArgumentError){ @pipe.write }      # Must have 1 argument
      assert_raises(Pipe::Error){ @pipe.write("foo") } # Nothing to write to
   end

   def test_disconnect
      assert_respond_to(@pipe, :disconnect)
      assert_nothing_raised{ @pipe.disconnect }
   end

   def test_close
      assert_respond_to(@pipe, :close)
      assert_nothing_raised{ @pipe.close }
   end
   
   def test_pipe_mode_constants
      assert_not_nil(Pipe::WAIT)
      assert_not_nil(Pipe::NOWAIT)
      assert_not_nil(Pipe::TYPE_BYTE)
      assert_not_nil(Pipe::TYPE_MESSAGE)
      assert_not_nil(Pipe::READMODE_BYTE)
      assert_not_nil(Pipe::READMODE_MESSAGE)
   end

   def test_open_mode_constants
      assert_not_nil(Pipe::ACCESS_DUPLEX)
      assert_not_nil(Pipe::ACCESS_INBOUND)
      assert_not_nil(Pipe::ACCESS_OUTBOUND)
      assert_not_nil(Pipe::FIRST_PIPE_INSTANCE)
      assert_not_nil(Pipe::WRITE_THROUGH)
      assert_not_nil(Pipe::OVERLAPPED)
   end

   def test_other_constants
      assert_not_nil(Pipe::INFINITE)
   end
   
   def teardown
      @pipe.close
      @pipe = nil
   end
end
