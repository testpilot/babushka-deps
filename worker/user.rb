dep 'user exists', :username do
  setup {
    define_var :home_dir_base, :default => L{
      username.to_s['.'] ? '/srv/http' : '/home'
    }
  }
  on :linux do
    met? { grep(/^#{username}:/, '/etc/passwd') }
    meet {
      sudo "mkdir -p #{var :home_dir_base}" and
      sudo "useradd -m -s /bin/bash -b #{var :home_dir_base} -G admin #{username}" and
      sudo "chmod 701 #{var(:home_dir_base) / username}"
    }
  end
end

dep('system user exists', :username) {
  met? { grep(/^#{username}:/, '/etc/passwd') }
  meet {
    sudo "useradd --system #{username}"
  }
}
