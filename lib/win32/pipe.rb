require File.join(File.dirname(__FILE__), 'pipe', 'windows', 'constants')
require File.join(File.dirname(__FILE__), 'pipe', 'windows', 'functions')
require File.join(File.dirname(__FILE__), 'pipe', 'windows', 'structs')

# The Win32 module serves as a namespace only.
module Win32
  # The Pipe class is an abstract base class for the Pipe::Server and
  # Pipe::Client classes. Do not use this directly.
  #
  class Pipe
    include Windows::Constants
    include Windows::Functions
    include Windows::Structs

    # Error raised when anything other than a SystemCallError occurs.
    class Error < StandardError; end

    # The version of this library
    VERSION = '0.4.0'

    DEFAULT_PIPE_BUFFER_SIZE = 4096 #:nodoc:
    PIPE_TIMEOUT = 5000    #:nodoc:

    # Blocking mode is enabled
    WAIT = PIPE_WAIT

    # Nonblocking mode is enabled
    NOWAIT = PIPE_NOWAIT

    # The pipe is bi-directional. Both server and client processes can read
    # from and write to the pipe.
    ACCESS_DUPLEX = PIPE_ACCESS_DUPLEX

    # The flow of data in the pipe goes from client to server only.
    ACCESS_INBOUND = PIPE_ACCESS_INBOUND

    # The flow of data in the pipe goes from server to client only.
    ACCESS_OUTBOUND = PIPE_ACCESS_OUTBOUND

    # Data is written to the pipe as a stream of bytes.
    TYPE_BYTE = PIPE_TYPE_BYTE

    # Data is written to the pipe as a stream of messages.
    TYPE_MESSAGE = PIPE_TYPE_MESSAGE

    # Data is read from the pipe as a stream of bytes.
    READMODE_BYTE = PIPE_READMODE_BYTE

    # Data is read from the pipe as a stream of messages.
    READMODE_MESSAGE = PIPE_READMODE_MESSAGE

    # All instances beyond the first will fail with access denied errors.
    FIRST_PIPE_INSTANCE = FILE_FLAG_FIRST_PIPE_INSTANCE

    # Functions do not return until the data is written across the network.
    WRITE_THROUGH = FILE_FLAG_WRITE_THROUGH

    # Overlapped mode enables asynchronous communication.
    OVERLAPPED = FILE_FLAG_OVERLAPPED

    # The default pipe mode
    DEFAULT_PIPE_MODE = PIPE_WAIT

    # The default open mode
    DEFAULT_OPEN_MODE = FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH

    # The data still in the pipe's buffer
    attr_reader :buffer

    # The number of bytes to be written to the pipe.
    attr_reader :size

    # The number of characters that are actually transferred over the pipe.
    attr_reader :transferred

    # The full name of the pipe, e.g. "\\\\.\\pipe\\my_pipe"
    attr_reader :name

    # The pipe mode of the pipe.
    attr_reader :open_mode

    # The open mode of the pipe.
    attr_reader :pipe_mode

    # Abstract initializer for base class. This handles automatic prepending
    # of '\\.\pipe\' to each named pipe so that you don't have to.  Don't
    # use this directly. Add the full implementation in subclasses.
    #
    # The default pipe mode is PIPE_WAIT.
    #
    # The default open mode is FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH.
    #
    def initialize(name, pipe_mode = DEFAULT_PIPE_MODE, open_mode = DEFAULT_OPEN_MODE, pipe_buffer_size = DEFAULT_PIPE_BUFFER_SIZE)
      @name = "\\\\.\\pipe\\" + name

      @pipe_mode = pipe_mode.nil? ? DEFAULT_PIPE_MODE : pipe_mode
      @open_mode = open_mode.nil? ? DEFAULT_OPEN_MODE : open_mode

      @pipe         = nil
      @pending_io   = false
      @buffer       = ''
      @ffi_buffer   = FFI::Buffer.new( pipe_buffer_size )
      @size         = 0
      @overlapped   = nil
      @transferred  = 0
      @asynchronous = false
      @pipe_buffer_size = pipe_buffer_size

      if open_mode & FILE_FLAG_OVERLAPPED > 0
        @asynchronous = true
      end

      if @asynchronous
        @event = CreateEvent(nil, 1, 1, nil)
        @overlapped = Overlapped.new
        @overlapped[:hEvent] = @event
      end
    end

    # Disconnects the pipe.
    def disconnect
      DisconnectNamedPipe(@pipe) if @pipe
    end

    # Closes the pipe.
    #
    def close
      CloseHandle(@pipe) if @pipe
    end

    # Returns whether or not there is a pending IO operation on the pipe.
    #
    def pending?
      @pending_io
    end

    # Returns whether or not the pipe is asynchronous.
    #
    def asynchronous?
       @asynchronous
    end

    # Reads data from the pipe. You can read data from either end of a named
    # pipe.
    #
    def read(read_size = @ffi_buffer.size)
      bytes = FFI::MemoryPointer.new(:ulong)

      raise Error, "no pipe created" unless @pipe

      if @asynchronous
        bool = ReadFile(@pipe, @ffi_buffer, read_size, bytes, @overlapped)
        bytes_read = bytes.read_ulong

        if bool && bytes_read > 0
          @pending_io = false
          @buffer = @ffi_buffer.get_string(0, bytes_read)
          return true
        end

        error = GetLastError()
        if !bool && error == ERROR_IO_PENDING
          @pending_io = true
          return true
        end

        return false
      else
        unless ReadFile(@pipe, @ffi_buffer, read_size, bytes, nil)
          raise SystemCallError.new("ReadFile", FFI.errno)
        end
        @buffer = @ffi_buffer.get_string(0, bytes.read_ulong)
      end
    end

    # Writes 'data' to the pipe. You can write data to either end of a
    # named pipe.
    #
    def write(data)
      bytes = FFI::MemoryPointer.new(:ulong)

      raise Error, "no pipe created" unless @pipe

      if @asynchronous
        bool = WriteFile(@pipe, data, data.size, bytes, @overlapped)
        bytes_written = bytes.read_ulong

        if bool && bytes_written > 0
          @pending_io = false
          return true
        end

        error = GetLastError()
        if !bool && error == ERROR_IO_PENDING
          @pending_io = true
          return true
        end

        return false
      else
        unless WriteFile(@pipe, data, data.size, bytes, nil)
          raise SystemCallError.new("WriteFile", FFI.errno)
        end

        return true
      end
    end

    # Returns the pipe object if an event (such as a client connection)
    # occurs within the +max_time+ specified (in seconds). Otherwise, it
    # returns false.
    #
    def wait(max_time = nil)
      unless @asynchronous
        raise Error, 'cannot wait in synchronous (blocking) mode'
      end

      max_time = max_time ? max_time * 1000 : INFINITE

      wait = WaitForSingleObject(@event, max_time)

      if wait == WAIT_TIMEOUT
        return false
      else
        if wait != WAIT_OBJECT_0
          raise SystemCallError.new("WaitForSingleObject", FFI.errno)
        end
      end

      if @pending_io
        transferred = FFI::MemoryPointer.new(:ulong)
        bool = GetOverlappedResult(@pipe, @overlapped, transferred, 0)

        unless bool
          raise SystemCallError.new("GetOverlappedResult", FFI.errno)
        end

        @transferred = transferred.read_ulong
        @buffer = @ffi_buffer.get_string(0, @transferred)
      end

      self
    end

    alias length size
  end
end

require File.join(File.dirname(__FILE__), 'pipe', 'server')
require File.join(File.dirname(__FILE__), 'pipe', 'client')
