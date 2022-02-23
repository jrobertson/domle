Gem::Specification.new do |s|
  s.name = 'domle'
  s.version = '0.6.0'
  s.summary = 'Domle (DOM + Rexle) is the document object model used by the Svgle gem'
  s.authors = ['James Robertson']
  s.files = Dir['lib/domle.rb']
  s.add_runtime_dependency('rexle', '~> 1.5', '>=1.5.14')
  s.add_runtime_dependency('csslite', '~> 0.2', '>=0.2.0')
  s.add_runtime_dependency('rxfreader', '~> 0.2', '>=0.2.1')
  s.signing_key = '../privatekeys/domle.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/domle'
end
