#########################################################################
# example_client.rb
#
# Simple client test.  Be sure to start the server first in a separate
# terminal. You can run this example via the 'rake example_client' task.
#
# Modify this code as you see fit.
#########################################################################
require 'win32/pipe'
include Win32

Thread.new { loop { sleep 0.01 } } # Allow Ctrl-C

puts "VERSION: " + Pipe::VERSION

# Block form
Pipe::Client.new('foo') do |pipe|
   puts "Connected..."
   pipe.write("Ruby rocks!")
   data = pipe.read
   puts "Got [#{data}] back from server"
end

# Non-block form
#pclient = Pipe::Client.new('foo')
#puts "Connected..."
#pclient.write("Ruby rocks!")
#data = pclient.read
#puts "Got [#{data}] back from server"
#pclient.close