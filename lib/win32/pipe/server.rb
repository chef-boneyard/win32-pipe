# The Win32 module serves as a namespace only.
module Win32
  # The Pipe::Server class encapsulates the server side of a named pipe
  # connection.
  class Pipe::Server < Pipe

    # Creates and returns a new Pipe::Server instance, using +name+ as the
    # name for the pipe. Note that this does not actually connect the pipe.
    # Use Pipe::Server#connect for that.
    #
    # The default pipe_mode is PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT.
    #
    # The default open_mode is Pipe::ACCESS_DUPLEX.
    #--
    # The default pipe_mode also happens to be 0.
    #
    def initialize(name, pipe_mode = 0, open_mode = Pipe::ACCESS_DUPLEX, pipe_buffer_size = DEFAULT_PIPE_BUFFER_SIZE)
      super(name, pipe_mode, open_mode, pipe_buffer_size)

      @pipe = CreateNamedPipe(
        @name,
        @open_mode,
        @pipe_mode,
        PIPE_UNLIMITED_INSTANCES,
        pipe_buffer_size,
        pipe_buffer_size,
        PIPE_TIMEOUT,
        nil
      )

      if @pipe == INVALID_HANDLE_VALUE
        raise SystemCallError.new("CreateNamedPipe", FFI.errno)
      end

      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    # Enables the named pipe server process to wait for a client process
    # to connect to an instance of a named pipe. In other words, it puts
    # the server in 'connection wait' status.
    #
    # In synchronous mode always returns true on success. In asynchronous
    # mode returns true if there is pending IO, or false otherwise.
    #
    def connect
      if @asynchronous
        # An overlapped ConnectNamedPipe should return 0
        if ConnectNamedPipe(@pipe, @overlapped)
          raise SystemCallError.new("ConnectNamedPipe", FFI.errno)
        end

        error = GetLastError()

        case error
          when ERROR_IO_PENDING
            @pending_io = true
          when ERROR_PIPE_CONNECTED
            unless SetEvent(@event)
              raise Error, get_last_error(error)
            end
          when ERROR_PIPE_LISTENING, ERROR_SUCCESS
            # Do nothing
          else
            raise Error, get_last_error(error)
        end

        if @pending_io
          return false
        else
          return true
        end
      else
        unless ConnectNamedPipe(@pipe, nil)
          raise SystemCallError.new("ConnectNamedPipe", FFI.errno)
        end
      end

      return true
    end

    # Close the server. This will flush file buffers, disconnect the
    # pipe, and close the pipe handle.
    #
    def close
      FlushFileBuffers(@pipe)
      DisconnectNamedPipe(@pipe)
      super
    end
  end
end
