require 'rubygems'

Gem::Specification.new do |spec|
	spec.name       = 'win32-pipe'
	spec.version    = '0.4.0'
	spec.author     = 'Daniel J. Berger'
  spec.license    = 'Apache 2.0'
	spec.email      = 'djberg96@gmail.com'
	spec.homepage   = 'https://github.com/djberg96/win32-pipe'
	spec.summary    = 'An interface for named pipes on MS Windows' 
	spec.test_files = Dir['test/test_*.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = ['certs/djberg96_pub.pem']

	spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST']
	
	spec.add_dependency('ffi')
	spec.add_dependency('rake')
  spec.add_development_dependency('test-unit')
	
	spec.description = <<-EOF
    The win32-pipe library provides an interface for named pipes on Windows.
    A named pipe is a named, one-way or duplex pipe for communication
    between the pipe server and one or more pipe clients. 
  EOF
end
