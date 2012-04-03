dep 'git.managed' do
  requires 'ppa'.with('ppa:git-core/ppa')
  installs 'git'
  provides 'git >= 1.7.4.1'
end
