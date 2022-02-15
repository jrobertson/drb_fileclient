Gem::Specification.new do |s|
  s.name = 'drb_fileclient'
  s.version = '0.7.3'
  s.summary = 'Reads or writes files from a remote DRb server. ' + 
      'Simple as DfsFile.read  or DfsFile.write.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/drb_fileclient.rb']
  # 24 Feb 2022: A fix for the following is planned in the near future
  # Removed the dependency below to resolve circular dependency issue
  #s.add_runtime_dependency('dir-to-xml', '~> 1.1', '>=1.1.2')
  s.signing_key = '../privatekeys/drb_fileclient.pem'
  s.add_runtime_dependency('zip', '~> 2.0', '>=2.0.2')
  s.add_runtime_dependency('c32', '~> 0.3', '>=0.3.0')
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/drb_fileclient'
end
