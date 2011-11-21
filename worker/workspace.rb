dep('workspace setup') {
  requires 'root bashrc rendered', 'bashrc rendered', 'test_environment rendered', 'germrc rendered', 'known hosts rendered', 'workspace directory exists'
}

dep('root bashrc rendered') {
  source = 'workspace/root_dot_bashrc.erb'
  to = '/root/.bashrc'

  met? { shell?("grep 'Generated by babushka' #{to}", :sudo => true) }
  meet { render_erb source, :to => to, :sudo => true }
}

dep('bashrc rendered') {
  source = 'workspace/dot_bashrc.erb'
  to = '/home/ubuntu/.bashrc'

  met? { shell?("grep 'Generated by babushka' #{to}") }
  meet { render_erb source, :to => to }
}

dep('test_environment rendered') {
  source = 'workspace/test_environment.sh.erb'
  to = '/etc/profile.d/test_environment.sh'

  met? { shell?("sudo grep 'Generated by babushka' #{to}") }
  meet {
    render_erb source, :to => to, :sudo => true
    shell "chown ubuntu:ubuntu #{to}", :sudo => true
    shell "chmod 0755 #{to}", :sudo => true
  }
}

dep('germrc rendered') {
  source = 'workspace/gemrc.erb'
  to = '/home/ubuntu/.gemrc'

  met? { shell?("grep 'Generated by babushka' #{to}") }
  meet { render_erb source, :to => to }
}

dep('known hosts rendered') {
  source = 'workspace/known_hosts.erb'
  to = '/home/ubuntu/.ssh/known_hosts'

  met? { shell?("grep 'Generated by babushka' #{to}") }
  meet {
    render_erb source, :to => to
    shell "mkdir -p /home/ubuntu/.ssh"
    shell "chmod 0755 /home/ubuntu/.ssh"
    shell "chmod 0600 #{to}"
  }
}

dep('workspace directory exists') {
  met? { "/home/ubuntu/workspace".p.exists? }
  meet { shell "mkdir -p /home/ubuntu/workspace" }
}
