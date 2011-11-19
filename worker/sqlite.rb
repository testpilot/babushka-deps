dep('sqlite installed') {
  requires 'sqlite3.managed'
}

dep('sqlite3.managed') {
  installs { via :apt, 'sqlite3', 'sqlite3-doc', 'libsqlite3-dev'}
  provides ['sqlite']
}

