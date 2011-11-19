dep('build essential installed') {
  requires [
    'build-essential',
    'binutils-doc.managed',
    'autoconf.managed',
    'flex.managed',
    'bison.managed'
  ]
}

dep('binutils-doc.managed') {
  provides []
}

dep('autoconf.managed') {}

dep('flex.managed') {}

dep('bison.managed') {}
