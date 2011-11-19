dep('yaml configured'){
  requires [
    'libyaml-0-2.managed',
    'libyaml-dev.managed'
  ]
}

dep('libyaml-0-2.managed') {
  provides []
}

dep('libyaml-dev.managed') {
  provides []
}
