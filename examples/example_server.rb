#########################################################################
# example_server.rb
#
# A simple named pipe server.  Start this up in its own terminal window.
# You may have to use the task manager to kill it if you don't connect
# with the test client program.
#
# You can start this server with the 'rake example_server' task. Modify
# this code as you see fit.
#########################################################################
require 'win32/pipe'
include Win32

Thread.new { loop { sleep 0.01 } } # Allow Ctrl-C

puts "VERSION: " + Pipe::VERSION

# Block form
Pipe::Server.new('foo') do |pipe|
   pipe.connect
   data = pipe.read
   puts "Got [#{data}]"
   pipe.write "Thanks for the data!"
end

# Non-block form
#pserver = Pipe::Server.new('foo')
#pserver.connect # put server in wait connect
#data = pserver.read
#puts "Got [#{data}]"
#pserver.write("Thanks for the data!")
#pserver.disconnect
#pserver.close