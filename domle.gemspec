Gem::Specification.new do |s|
  s.name = 'domle'
  s.version = '0.1.0'
  s.summary = 'The document object model used by the Svgle gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/domle.rb']
  s.add_runtime_dependency('rexle', '~> 1.3', '>=1.3.9')
  s.add_runtime_dependency('rxfhelper', '~> 0.2', '>=0.2.3')
  s.signing_key = '../privatekeys/domle.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/domle'
end
