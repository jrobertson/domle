Gem::Specification.new do |s|
  s.name = 'domle'
  s.version = '0.3.1'
  s.summary = 'Domle (DOM + Rexle) is the document object model used by the Svgle gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/domle.rb']
  s.add_runtime_dependency('rexle', '~> 1.5', '>=1.5.1')
  s.add_runtime_dependency('csslite', '~> 0.1', '>=0.1.3')
  s.add_runtime_dependency('rxfhelper', '~> 0.9', '>=0.9.4')
  s.signing_key = '../privatekeys/domle.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/domle'
end
