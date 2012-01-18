dep 'user exists', :username, :home_dir_base do
  home_dir_base.default!(username['.'] ? '/srv/http' : '/home')

  on :linux do
    met? { grep(/^#{username}:/, '/etc/passwd') }
    meet {
      sudo "mkdir -p #{home_dir_base}" and
      sudo "useradd -m -s /bin/bash -b #{home_dir_base} -G builder #{username}" and
      sudo "chmod 701 #{home_dir_base / username}"
    }

    after {
      unmeetable! "You must login as ubuntu and run babushka again to continue setup" unless shell('whoami') == 'ubuntu'
    }
  end
end

dep('system user exists', :username) {
  met? { grep(/^#{username}:/, '/etc/passwd') }
  meet {
    sudo "useradd --system #{username}"
  }
}

dep 'builders can sudo' do
  requires 'builder group'
  met? { !sudo('cat /etc/sudoers').split("\n").grep(/^%builder/).empty? }
  meet { append_to_file '%builder  ALL=(ALL) ALL', '/etc/sudoers', :sudo => true }
end

dep 'builder group' do
  met? { grep(/^builder\:/, '/etc/group') }
  meet { sudo 'groupadd builder' }
end

dep('ubuntu user exists') {
  requires 'builders can sudo', 'user exists'.with('ubuntu', '/home')
}

