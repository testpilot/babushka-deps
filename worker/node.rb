dep('nodejs installed') {
  requires 'nodejs.src'
}

dep 'nodejs.src' do
  source 'git://github.com/joyent/node.git'
  provides 'node', 'node-waf'
end
