require 'rubygems'

Gem::Specification.new do |gem|
	gem.name       = 'win32-pipe'
	gem.version    = '0.2.2'
	gem.author     = 'Daniel J. Berger'
  gem.license    = 'Artistic 2.0'
	gem.email      = 'djberg96@gmail.com'
	gem.homepage   = 'http://www.rubyforge.org/projects/win32utils'
	gem.platform   = Gem::Platform::RUBY
	gem.summary    = 'An interface for named pipes on MS Windows' 
	gem.test_files = Dir['test/test_*.rb']
	gem.has_rdoc   = true
  gem.files      = Dir['**/*'].reject{ |f| f.include?('git') }

	gem.rubyforge_project = 'win32utils'
	gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']
	
	gem.add_dependency('windows-pr', '>= 1.0.6')
  gem.add_development_dependency('test-unit', '>= 2.1.0')
	
	gem.description = <<-EOF
    The win32-pipe library provides an interface for named pipes on Windows.
    A named pipe is a named, one-way or duplex pipe for communication
    between the pipe server and one or more pipe clients. 
  EOF
end
