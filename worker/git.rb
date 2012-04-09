dep('git installed') {
  requires 'git-core.managed'
}

dep('git-core.managed'){
  installs ['git-core', 'git-man']
  provides 'git >= 1.7.0.4'
}

# dep 'git.managed' do
#   before {
#     shell "sudo touch /etc/apt/sources.list.d/babushka.list"
#     shell "sudo chown ubuntu:ubuntu  /etc/apt/sources.list.d/babushka.list"
#   }
# 
#   requires 'ppa'.with('ppa:git-core/ppa')
#   installs 'git'
#   provides 'git >= 1.7.4.1'
# 
#   after {
#     shell "sudo chown root:root /etc/apt/sources.list.d/babushka.list"
#   }
# end
# 
# 
