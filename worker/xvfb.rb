dep('xvfb installed') {
  requires 'xvfb.managed', 'xvfb service', 'Xvfb on startup'
}

dep('xvfb.managed') {
  installs { via :apt, *%w[xserver-xorg-core xvfb xfonts-base xfonts-75dpi xfonts-100dpi] }
  provides []
}

dep('xvfb service') {
  met? { shell?("grep ':1 -ac -screen 0 1024x768x24' /etc/init.d/xvfb", :sudo => true) }

  meet {
    render_erb "xvfb/xvfb.sh.erb", :to => '/etc/init.d/xvfb', :sudo => true
    shell "chmod 0751 /etc/init.d/xvfb", :sudo => true
  }
}

dep('Xvfb on startup') {
  met? { sudo "test -x /etc/rc0.d/K20xvfb" }

  meet {
    sudo "update-rc.d xvfb defaults"
  }
}
