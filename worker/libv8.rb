dep('libv8 installed'){
  requires 'libv8.managed'
}

dep('libv8.managed') {
  installs {
    via :apt, 'libv8-2.0.3', 'libv8-dev', 'libv8-dbg'
  }
  provides []
}
