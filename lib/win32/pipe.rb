require 'windows/pipe'
require 'windows/synchronize'
require 'windows/handle'
require 'windows/file'
require 'windows/error'

# The Win32 module serves as a namespace only.
module Win32
   # The Pipe class is an abstract base class for the Pipe::Server and
   # Pipe::Client classes. Do not use this directly.
   #
   class Pipe
      include Windows::Pipe
      include Windows::Synchronize
      include Windows::Handle
      include Windows::File
      include Windows::Error
      
      # Error typically raised if any of the Pipe methods fail.
      class Error < StandardError; end
      
      # The version of this library
      VERSION = '0.2.2'

      PIPE_BUFFER_SIZE = 512 #:nodoc:
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
      DEFAULT_PIPE_MODE = NOWAIT

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
      def initialize(name, pipe_mode = DEFAULT_PIPE_MODE, open_mode = DEFAULT_OPEN_MODE)
         @name = "\\\\.\\pipe\\" + name

         @pipe_mode = pipe_mode.nil? ? DEFAULT_PIPE_MODE : pipe_mode
         @open_mode = open_mode.nil? ? DEFAULT_OPEN_MODE : open_mode

         @pipe         = nil
         @pending_io   = false
         @buffer       = 0.chr * PIPE_BUFFER_SIZE
         @size         = 0
         @overlapped   = 0.chr * 20 # sizeof(OVERLAPPED)
         @transferred  = 0
         @asynchronous = false

         if open_mode & FILE_FLAG_OVERLAPPED > 0
            @asynchronous = true
         end

         if @asynchronous
            @event = CreateEvent(nil, true, true, nil)
            @overlapped[16, 4] = [@event].pack('L')
         end
      end
      
      # Disconnects the pipe.
      def disconnect
         DisconnectNamedPipe(@pipe)
      end
      
      # Closes the pipe.
      # 
      def close
         CloseHandle(@pipe)
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
      def read
         bytes = [0].pack('L')
         @buffer = 0.chr * PIPE_BUFFER_SIZE
         
         if @asynchronous
            bool = ReadFile(@pipe, @buffer, @buffer.size, bytes, @overlapped)

            bytes_read = bytes.unpack('L').first

            if bool && bytes_read > 0
               @pending_io = false
               @buffer = @buffer[0, bytes_read]
               return true
            end

            error = GetLastError()
            if !bool && error == ERROR_IO_PENDING
               @pending_io = true
               return true
            end

            return false
         else
            unless ReadFile(@pipe, @buffer, @buffer.size, bytes, nil)
               raise Error, get_last_error
            end
         end
         
         @buffer.unpack("A*")
      end
      
      # Writes 'data' to the pipe. You can write data to either end of a
      # named pipe.
      # 
      def write(data)
         @buffer = data
         @size   = data.size
         bytes   = [0].pack('L')

         if @asynchronous
            bool = WriteFile(@pipe, @buffer, @buffer.size, bytes, @overlapped)

            bytes_written = bytes.unpack('L').first

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
            unless WriteFile(@pipe, @buffer, @buffer.size, bytes, 0)
               raise Error, get_last_error
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
               raise Error, get_last_error
            end
         end

         if @pending_io
            transferred = [0].pack('L')
            bool = GetOverlappedResult(@pipe, @overlapped, transferred, false)

            unless bool
               raise Error, get_last_error
            end

            @transferred = transferred.unpack('L')[0]
            @buffer = @buffer[0, @transferred]
         end

         self
      end
      
      alias length size
   end
end

require 'win32/pipe/server'
require 'win32/pipe/client'
