dep('mysql installed'){
  requires 'mysql.managed', 'mysql server installed'
}

dep('mysql.managed') {
  installs { via :apt, 'mysql-client', 'libmysqlclient-dev', 'libmysql-ruby' }
}

dep('mysql server installed') {
  requires 'preseeding directory', 'mysql server seeded', 'mysql server configured', 'mysql-server.managed'
}

dep('preseeding directory') {
  met? {
    sudo "stat /var/cache/local/preseeding"
  }

  meet {
    sudo "mkdir -p /var/cache/local/preseeding"
    sudo "chmod 0755 /var/cache/local/preseeding"
  }
}

dep('mysql server seeded') {
  met? { sudo "stat /var/cache/local/preseeding/mysql-server.seed" }
  meet {
    render_erb('mysql/mysql-server.seed.erb', :to => '/var/cache/local/preseeding/mysql-server.seed', :sudo => true)
    sudo "debconf-set-selections /var/cache/local/preseeding/mysql-server.seed"
  }
}

dep('mysql server configured') {
  met? { sudo "stat /etc/mysql/debian.cnf" }
  meet {
    render_erb 'mysql/debian.cnf.erb', :to => '/etc/mysql/debian.cnf', :sudo => true
    sudo "chmod 0600 /etc/mysql/debian.cnf"
  }
}

dep('mysql-server.managed') {
  installs { via :apt, 'mysql-server'}
  provides []
}
