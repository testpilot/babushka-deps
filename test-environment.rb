dep('test environment') {
  requires [
    # 'language-pack-en.managed',
    'set.locale',
    'core dependencies',
    'build essential installed',
    'python build environment',
    'yaml configured',
    'timetrap configured',
    'git.managed',
    'libqt4 installed',
    'libv8 installed',

    # Databases
    'sqlite installed',
    'postgresql installed',

    # Language environments
    'ruby environment'.with('1.8.7, 1.9.2, 1.9.3', 'ree')
  ]
}
