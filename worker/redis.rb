dep('redis installed') {
  requires 'redis directories setup', 'redis-server.managed'
}

dep('redis directories setup') {
  requires 'system user exists'.with('redis')

  def directories
    ['/var/lib/redis', '/var/log/redis'].map(&:p)
  end

  met? {
    directories.all? do |dir|
      dir.exists?
    end
  }

  meet {
    directories.all? do |dir|
      shell "mkdir -p #{dir}", :sudo => true
      shell "chown redis #{dir}", :sudo => true
    end
  }
}

dep('redis-server.managed') {
  installs { via :apt, 'redis-server' }
  after {
    shell "update-rc.d redis-server defaults", :sudo => true
    shell "service redis-server start", :sudo => true
  }
}
