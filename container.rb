dep('test container provisioned', :name, :bind_ip, :bind_port) {
  bind_ip.default! 'localhost'
  bind_port.default! '2222'
  name.default! 'build-1'

  requires 'base container cloned'
}

# Installs everything to get a host running from scratch
dep('lxc host configured') {
  requires  'build essential installed',
            'lxc dependencies installed',
            'zlib1g.managed',
            'libxslt-dev.managed',
            'ncurses-dev.managed',
            'lvm2.managed',
            'lxc.managed',
            'cgroup mounted',
            'bridge interface up',
            'rvm with multiple rubies',
            'required.rubies_installed'.with('1.9.3'),
            'bundler.global_gem'.with('1.9.3')
}

packages = %w(openssl libreadline6 libreadline6-dev curl git-core zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf libc6-dev  automake libtool bison)

packages.each do |package|
  if package =~ /^lib|\-dev$/
    dep("#{package}.managed") { provides [] }
  else
    dep "#{package}.managed"
  end
end

dep('ncurses-dev.managed') { provides [] }
dep('zlib1g.managed') { provides [] }
dep('lvm2.managed') { provides 'lvm' }
dep('lxc.managed') { provides 'lxc-start' }
dep('bridge-utils.managed') { provides 'brctl' }
dep('libxslt-dev.managed') { 
  provides []
  installs 'libxslt1-dev'
}

dep('lxc dependencies installed') {
  requires packages.map { |p| "#{p}.managed" }
}

dep('cgroup mounted') {
  met? { shell? "grep cgroup /etc/fstab", :sudo => true }
  meet {
    log_shell "Creating cgroup mount point", "mkdir -p /cgroup", :sudo => true
    log_shell "Adding cgroup to fstab", 'echo "none /cgroup cgroup defaults 0 0" >>/etc/fstab', :sudo => true
    log_shell "Mounting cgroup", 'mount /cgroup', :sudo => true
  }
}

dep('allow ip forwarding') {
  met? {
    shell? "test -s /etc/sysctl.d/20-lxc.conf", :sudo => true
  }
  meet {
    config = %s(net.ipv4.ip_forward = 1)
    render_erb(StringIO.new(config), :to => '/etc/sysctl.d/20-lxc.conf', :sudo => true)
    shell "sysctl -w net.ipv4.ip_forward=1", :sudo => true
  }
}

dep('bridge interface up') {
  requires 'bridge-utils.managed', 'allow ip forwarding'
  met? {
    "/etc/network/interfaces".p.grep("br0")
  }
  meet {
    shell "brctl add br0", :sudo => true
    config = <<EOF
auto br0
iface br0 inet static
address 192.168.50.1
netmask 255.255.255.0
EOF
    append_to_file(config, '/etc/network/interfaces', :sudo => true)
  }
}

dep('base container cloned', :name, :base_image_name) {
  base_image_name.default! 'baseimage'

  def lxc_dir
    '/var/lib/lxc'.p
  end

  def root_fs
    lxc_dir / var(:name) / 'rootfs'
  end

  met? {
    shell? "lxc-ls | grep '#{var(:name)}'"
  }

  meet {
    shell "/usr/bin/lxc-clone -o #{base_image_name} -s -n #{name}"
  }
}



