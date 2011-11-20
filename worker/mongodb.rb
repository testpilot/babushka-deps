# This is based on the travis-ci mongo chef cookbook

dep('mongodb installed') {
  requires 'mongodb.apt_repository', 'mongo.directories', 'mongodb.managed', 'mongodb sysv init script'
}

dep('mongodb.apt_repository') {
  requires 'mongodb apt source key'
  uri 'http://downloads-distro.mongodb.org/repo/debian-sysvinit'
  repo_name '10gen'
  distro 'dist'
}

dep('mongodb apt source key') {
  met? {
    shell?('apt-key list | grep 7F0CEB10', :sudo => true)
  }

  meet {
    shell "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10", :sudo => true
  }
}

dep('mongodb.managed') {
  installs { via :apt, 'mongodb' }
  provides []
}

dep('mongodb sysv init script') {
  met? {
    babushka_config?('/etc/init.d/mongodb')
  }

  meet {
    render_erb('mongodb/mongodb.syscinit.sh.erb', :to => '/etc/init.d/mongodb', :sudo => true, :perms => '0751')
  }
}

dep('mongo.directories') {
  directories '/var/lib/mongodb'
  perms 0755
}
