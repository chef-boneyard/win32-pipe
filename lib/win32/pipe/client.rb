# The Win32 module serves as a namespace only
module Win32
   # The Pipe::Client class encapsulates the client side of a named pipe
   # connection.
   #
   class Pipe::Client < Pipe
      # Create and return a new Pipe::Client instance.
      #
      # The default pipe mode is PIPE_WAIT.
      #
      # The default open mode is FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH.
      #--
      # 2147483776 is FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH
      def initialize(name, pipe_mode = DEFAULT_PIPE_MODE, open_mode = DEFAULT_OPEN_MODE)
         super(name, pipe_mode, open_mode)
         
         @pipe = CreateFile(
            @name,
            GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE,
            nil,
            OPEN_EXISTING,
            @open_mode,
            nil 
         )

         error = GetLastError()
         
         if error == ERROR_PIPE_BUSY
            unless WaitNamedPipe(@name, NMPWAIT_WAIT_FOREVER)
               raise Error, get_last_error
            end
         end
         
         if @pipe == INVALID_HANDLE_VALUE
            raise Error, get_last_error
         end
         
         if block_given?
            begin
               yield self
            ensure
               disconnect
               close
            end
         end
      end
   end
end
