dep('xvfb installed') {
  requires 'xvfb.managed', 'xvfb service'
}

dep('xvfb.managed') {
  installs { via :apt, 'xserver-xorg-core', 'xvfb' }
  provides []
}

dep('xvfb service') {
  met? {
    shell?('test -x /etc/init.d/xvfb', :sudo => true)
  }

  meet {
    render_erb "xvfb/xvfb.sh.erb", :to => '/etc/init.d/xvfb', :sudo => true
    shell "chmod 0751 /etc/init.d/xvfb", :sudo => true
  }
}