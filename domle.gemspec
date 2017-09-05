Gem::Specification.new do |s|
  s.name = 'domle'
  s.version = '0.1.12'
  s.summary = 'Domle (DOM + Rexle) is the document object model used by the Svgle gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/domle.rb']
  s.add_runtime_dependency('rexle', '~> 1.4', '>=1.4.7')
  s.add_runtime_dependency('rxfhelper', '~> 0.4', '>=0.4.2')
  s.signing_key = '../privatekeys/domle.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/domle'
end
