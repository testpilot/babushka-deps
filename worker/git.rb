dep('git installed') {
  requires 'git.managed'
}

# dep('git-core.managed'){
#   installs []
#   provides 'git >= 1.7.0.4'
# }

dep 'git.managed' do
  before {
    shell "touch /etc/apt/sources.list.d/babushka.list", :sudo => true
    shell "sudo chown ubuntu:ubuntu  /etc/apt/sources.list.d/babushka.list"
  }
  requires 'ppa'.with('ppa:git-core/ppa')
  installs 'git'
  provides 'git >= 1.7.4.1'
end


