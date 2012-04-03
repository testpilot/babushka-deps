dep('git installed') {
  requires 'benhoskings:git.src'
}
# dep 'git.managed' do
#   before {
#     shell "touch /etc/apt/sources.list.d/babushka.list", :sudo => true
#     shell "chown ubuntu:ubuntu /etc/apt/sources.list.d/babushka.list", :sudo => true
#   }
#   requires 'ppa'.with('ppa:git-core/ppa')
#   installs 'git'
#   provides 'git >= 1.7.4.1'
# end
#
#
