dep 'git.ppa' do
  adds 'ppa:git-core/ppa'
end

dep 'git.managed' do
  requires 'git.ppa'
  installs 'git'
  provides 'git >= 1.7.4.1'
end
