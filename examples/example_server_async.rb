#######################################################################
# example_server_async.rb
#
# A simple, asynchronous named pipe server. Start this up in its own
# terminal window. You can run this program via the
# 'rake example_async_server' task.
#######################################################################
require 'win32/pipe'
include Win32

puts "VERSION: " + Pipe::VERSION

Thread.new { loop { sleep 0.01 } } # Allow Ctrl-C

CONNECTING_STATE = 0
READING_STATE    = 1
WRITING_STATE    = 2

class MyPipe < Pipe::Server
   def connected
      puts "connected"
      @state = READING_STATE
   end
   
   def read_complete
      puts "read_complete"
      puts "Got [#{buffer}]"       
      @state = WRITING_STATE
   end
   
   def write_complete
      puts "write_complete"
      disconnect
      @state = CONNECTING_STATE
   end
   
   def reconnect
      disconnect
      mainloop
   end
   
   def mainloop
      @state = CONNECTING_STATE
      while true
         if wait(1)          # wait for 1 second
            if pending?      # IO is pending
               case @state
                  when CONNECTING_STATE
                     connected
                  when READING_STATE
                     if transferred == 0
                        reconnect
                        break
                     end
                     read_complete
                  when WRITING_STATE
                     if transferred != length
                        reconnect
                        break
                     end
                     write_complete
               end
            end

            case @state
               when CONNECTING_STATE
                  if connect
                     connected
                  end 
               when READING_STATE
                  if read
                     if !pending?
                        read_complete
                     end
                  else
                      reconnect
                  end
               when WRITING_STATE
                  if write("Thanks for the data!")
                     if not pending?
                        write_complete
                     end
                  else
                     reconnect
                     break
                  end
               end
         end
 
         sleep(1)
         puts "pipe server is running"
      end
   end
end

flags = Pipe::ACCESS_DUPLEX | Pipe::OVERLAPPED

MyPipe.new('foo', 0, flags) do |pipe|
   pipe.mainloop
end
