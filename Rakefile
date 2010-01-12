require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc 'Install the win32-pipe library (non-gem)'
task :install do
   sitelibdir = CONFIG['sitelibdir']

   pipe_installdir = File.join(sitelibdir, 'win32')
   sub_installdir = File.join(sitelibdir, 'win32', 'pipe')

   pipe_file   = File.join('lib', 'win32', 'pipe.rb')
   client_file = File.join('lib', 'win32', 'pipe', 'client.rb')
   server_file = File.join('lib', 'win32', 'pipe', 'server.rb')
   
   FileUtils.mkdir_p(sub_installdir)

   FileUtils.cp(pipe_file, pipe_installdir, :verbose => true)   
   FileUtils.cp(client_file, sub_installdir, :verbose => true)   
   FileUtils.cp(server_file, sub_installdir, :verbose => true)   
end

desc 'Run the asynchronous client example program'
task :example_async_client do
   ruby '-Ilib examples/example_client_async.rb'
end

desc 'Run the client example program'
task :example_client do
   ruby '-Ilib examples/example_client.rb'
end

desc 'Run the asynchronous server example program'
task :example_async_server do
   ruby '-Ilib examples/example_server_async.rb'
end

desc 'Run the server example program'
task :example_server do
   ruby '-Ilib examples/example_server.rb'
end

Rake::TestTask.new do |test|
   test.warning = true
   test.verbose = true
end
