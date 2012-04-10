dep('base-template setup') {
  requires  'lxc host configured',
            'base template networking configured'
}

# Installs everything to get a host running from scratch
dep('lxc host configured') {
  requires  'build essential installed',
            'lxc dependencies installed',
            # 'xfsprogs.managed',
            'python-software-properties.managed',
            'zlib1g.managed',
            'git.managed',
            'man.managed',
            'libxslt-dev.managed',
            'ncurses-dev.managed',
            'lvm2.managed',
            'lxc.managed',
            # 'cgroup mounted',
            'bridge interface up',
            'rvm with multiple rubies',
            'required.rubies_installed'.with('1.9.3'),
            'bundler.global_gem'.with('1.9.3'),
            'lucid base template installed',
            'iptables masquerade',
            'deployable repo'
}

dep 'deployable repo', :path do
  requires [
    'benhoskings:web repo exists'.with(path),
    'benhoskings:web repo hooks'.with(path),
    'benhoskings:web repo always receives'.with(path)
  ]
  met? {
    vanity_path = path.p.sub(/^#{Etc.getpwuid(Process.euid).dir.chomp('/')}/, '~')
    log "All done. The repo's URI: " + "#{shell('whoami')}@#{shell('hostname -f')}:#{vanity_path}".colorize('underline')
    true
  }
end

packages = %w(openssl libreadline6 libreadline6-dev curl zlib1g-dev tcpdump libpcap-dev screen libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf libc6-dev  automake libtool bison)

packages.each do |package|
  if package =~ /^lib|\-dev$/
    dep("#{package}.managed") { provides [] }
  else
    dep "#{package}.managed"
  end
end

dep('ncurses-dev.managed') {
  provides []
  installs ['libncurses5', 'libncurses5-dev']
}
dep('xfsprogs.managed') { provides 'mkfs.xfs' }
dep('zlib1g.managed') { provides [] }
dep('lvm2.managed') { provides 'lvm' }
dep('lxc.managed') { provides 'lxc-start' }
dep('bridge-utils.managed') { provides 'brctl' }
dep('libxslt-dev.managed') {
  provides []
  installs 'libxslt1-dev'
}
dep('python-software-properties.managed') { provides [] }
dep('lxc dependencies installed') {
  requires packages.map { |p| "#{p}.managed" }
}
dep('man.managed') {
  installs 'manpages'
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
    shell "echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/20-lxc.conf", :sudo => true
    shell "sysctl -w net.ipv4.ip_forward=1", :sudo => true
  }
}

dep('iptables masquerade') {
  requires 'iptables-persistent.managed'

  met? {
    shell? "iptables -L -t nat | grep MASQUERADE", :sudo => true
  }
  meet {
    shell "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE", :sudo => true
    shell "iptables-save", :sudo => true
  }
}

dep('iptables-persistent.managed') { provides ['iptables-save'] }

dep('bridge interface up') {
  requires 'bridge-utils.managed', 'allow ip forwarding'
  met? {
    shell?("brctl showstp br0", :sudo => true) &&
    shell?("grep 'iface br0 inet static' /etc/network/interfaces")
  }
  meet {
    shell "brctl addbr br0", :sudo => true
    shell "sudo chown ubuntu:ubuntu /etc/network/interfaces"
    config = <<EOF
auto br0
iface br0 inet static
address 192.168.50.1
netmask 255.255.255.0
EOF
    '/etc/network/interfaces'.p.append(config)
    shell "sudo chown root:root /etc/network/interfaces"
    shell "ifup br0", :sudo => true
  }
}

dep('lxc default config') {
  met? {
    shell? 'test -s /etc/lxc-basic.conf'
  }
  meet {
    render_erb 'container/lxc/lxc-basic.conf.erb', :to => '/etc/lxc-basic.conf', :sudo => true
  }
}

dep('lucid base template installed') {
  requires ['lxc default config']

  met? {
    shell?("test -d /var/lib/lxc/base-template/rootfs") || shell?("test -b /dev/lxc/base-template -o -h /dev/lxc/base-template")
  }
  meet {
    shell "lxc-create -n base-template -f /etc/lxc-basic.conf -t ubuntu -- -r lucid", :sudo => true
  }
}

dep('base template networking configured') {
  requires ['base template configured to boot from lvm']
  met?{
    shell? "cat /mnt/base-template/etc/network/interfaces | grep 'iface eth0 inet static'"
  }
  meet {
    shell "rm -f /etc/networking/interfaces", :sudo => true
    render_erb "container/lxc/interfaces.erb", :to => "/mnt/base-template/etc/network/interfaces", :sudo => true
    shell "cat /mnt/base-template/etc/resolvconf/resolv.conf.d/original > /mnt/base-template/etc/resolvconf/resolv.conf.d/base", :sudo => true
  }
}

dep('base template on lvm ready for snapshot') {
  requires ['base template configured to boot from lvm', 'base template unmounted']
  met? {
    shell? "cat /var/lib/lxc/base-template/config | grep 'lxc.rootfs = /dev/lxc/base-template'", :sudo => true
  }
  meet {
    shell "rm -rf /var/lib/lxc/base-template/rootfs", :sudo => true
    shell "mkdir /var/lib/lxc/base-template/rootfs", :sudo => true
    shell "sed -i '/lxc.rootfs/d' /var/lib/lxc/base-template/config", :sudo => true
    shell "echo 'lxc.rootfs = /dev/lxc/base-template' >> /var/lib/lxc/base-template/config", :sudo => true
  }
}

dep('base template unmounted') {
  met? { !shell?("mount | grep base-template") }
  meet { shell "umount /mnt/base-template", :sudo => true }
}

dep('base template rsynced to lvm') {
  requires ['base-template volume mounted', 'lucid base template installed']
  met?{
    shell? 'test -d /mnt/base-template/home/', :sudo => true
  }
  meet {
    shell 'rsync -va /var/lib/lxc/base-template/rootfs/ /mnt/base-template/', :sudo => true
  }
}

dep('base template configured to boot from lvm'){
  requires 'base template rsynced to lvm'
  met? {
    shell? "grep '/dev/lxc/' /var/lib/lxc/base-template/config"
  }
  meet {
    shell "rm -rf /var/lib/lxc/base-template/rootfs/", :sudo => true
    shell "mkdir -p /var/lib/lxc/base-template/rootfs/", :sudo => true
    shell "sed -i '/lxc.rootfs/d' /var/lib/lxc/base-template/config", :sudo => true
    shell 'echo "lxc.rootfs = /dev/lxc/base-template" >> /var/lib/lxc/base-template/config', :sudo => true
  }
}

dep('base-template volume mounted') {
  requires 'base-template volume'
  met? {
    shell? "mount | grep base-template", :sudo => true
  }
  meet {
    shell "mkdir -p /mnt/base-template", :sudo => true
    shell "mount /dev/lxc/base-template /mnt/base-template", :sudo => true
  }
}

dep('base-template volume'){
  requires 'lxc volume group'

  met? {
    shell? "lvdisplay /dev/lxc/base-template", :sudo => true
  }
  meet{
    shell 'lvcreate -L 5G -n base-template lxc', :sudo => true
    shell 'mkfs.ext4 /dev/lxc/base-template', :sudo => true
  }
}

dep('lxc volume group', :device) {
  device.default! 'xvda2'

  met? {
    shell? "sudo vgdisplay lxc"
  }
  meet {
    shell "vgcreate lxc #{device}", :sudo => true
  }
}

dep('new lxc container cloned', :new_name, :base_image_name) {
  requires 'base template unmounted', 'container destroyed and cleaned up'.with(new_name)

  base_image_name.default! 'base-template'

  def lxc_dir
    '/var/lib/lxc'.p
  end

  def root_fs
    lxc_dir / new_name / 'rootfs'
  end

  met? {
    shell? "test -d #{root_fs}"
  }

  meet {
    shell "/usr/bin/lxc-clone -o #{base_image_name} -s -n #{new_name}", :sudo => true
  }
}

dep('container destroyed and cleaned up', :container_name) {
  requires 'logical volume removed'.with(container_name)
  met? {
    !shell?("lxc-ls | grep #{container_name}", :sudo => true)
  }

  meet {
    shell "lxc-stop -n #{container_name}", :sudo => true
    shell "lxc-destroy -n #{container_name}", :sudo => true
  }
}

dep('logical volume removed', :container_name) {
  met? { !shell?("lvdisplay | grep #{container_name}", :sudo => true) }
  meet { shell "lvremove -f /dev/lxc/#{container_name}", :sudo => true }
}

