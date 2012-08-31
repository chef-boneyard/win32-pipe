require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.gem")

namespace :gem do
  desc 'Create the win32-pipe gem'
  task :create => [:clean] do
    spec = eval(IO.read('win32-pipe.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc 'Install the win32-pipe gem'
  task :install => [:create] do
    file = Dir['*.gem'].first
    sh "gem install #{file}"
  end
end

namespace :example do
  desc 'Run the asynchronous client example program'
  task :async_client do
    ruby '-Ilib examples/example_client_async.rb'
  end

  desc 'Run the client example program'
  task :client do
    ruby '-Ilib examples/example_client.rb'
  end

  desc 'Run the asynchronous server example program'
  task :async_server do
    ruby '-Ilib examples/example_server_async.rb'
  end

  desc 'Run the server example program'
  task :server do
    ruby '-Ilib examples/example_server.rb'
  end
end

namespace :test do
  Rake::TestTask.new(:base) do |test|
    test.warning = true
    test.verbose = true
    test.test_files = FileList['test\test_win32_pipe.rb']
  end

  Rake::TestTask.new(:client) do |test|
    test.warning = true
    test.verbose = true
    test.test_files = FileList['test\test_win32_pipe_client.rb']
  end

  Rake::TestTask.new(:server) do |test|
    test.warning = true
    test.verbose = true
    test.test_files = FileList['test\test_win32_pipe_server.rb']
  end

  Rake::TestTask.new(:all) do |test|
    test.warning = true
    test.verbose = true
  end
end

task :default => 'test:all'
