Gem::Specification.new do |s|
  s.name = 'drb_fileclient'
  s.version = '0.8.1'
  s.summary = 'Reads or writes files from a remote DRb server. ' + 
      'Simple as DfsFile.read  or DfsFile.write.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/drb_fileclient.rb']
  s.signing_key = '../privatekeys/drb_fileclient.pem'
  s.add_runtime_dependency('zip', '~> 2.0', '>=2.0.2')
  s.add_runtime_dependency('dir-to-xml', '~> 1.2', '>=1.2.1')
  s.add_runtime_dependency('drb_fileclient-readwrite', '~> 0.1', '>=0.1.5')
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/drb_fileclient'
end
