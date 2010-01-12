#########################################################################
# example_client_async.rb
#
# Simple client test. Be sure to start the server first in a separate
# terminal. You can run this example via the 'rake example_async_client'
# task.
#########################################################################
require 'win32/pipe'
include Win32

puts "VERSION: " + Pipe::VERSION

Thread.new { loop { sleep 0.01 } } # Allow Ctrl-C

CONNECTING_STATE = 0
READING_STATE    = 1
WRITING_STATE    = 2

class MyPipe < Pipe::Client
   def read_complete
      puts "read_complete"
      puts "Got [#{buffer}] back from server"
      @state = WRITING_STATE
   end
    
   def write_complete
      puts "write_complete"
      @state = READING_STATE
   end
 
   def mainloop
      @state = WRITING_STATE
      while true
         if wait(1)          # wait for 1 second
            if pending?      # IO is pending
               case @state
                  when READING_STATE
                     if transferred == 0
                        reconnect
                        break
                     end
                     read_complete
                     break
                  when WRITING_STATE
                     if transferred != length
                        reconnect
                        break
                     end
                     write_complete
               end
            end

            case @state
               when READING_STATE
                  if read
                     if not pending?
                        read_complete
                        break
                     end
                  end
               when WRITING_STATE
                  if write("Ruby rocks!")
                     if not pending?
                        write_complete
                     end
                  end
            end
         end
	    
         sleep(1)
         puts "pipe client is running"
      end    
   end
end

flags = Pipe::DEFAULT_OPEN_MODE | Pipe::OVERLAPPED

MyPipe.new('foo', nil, flags) do |client|
   puts "Connected..."
   client.mainloop
end
    
