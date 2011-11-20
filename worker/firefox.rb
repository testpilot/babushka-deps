dep('firefox installed') {
  requires 'firefox.managed'
}

dep('firefox.managed') {
  installs { via :apt, 'firefox' }
}
