dep('test environment') {
  requires [
    'language-pack-en.managed',
    'core dependencies',
    'build essential installed',
    'python build environment',
    'yaml configured',
    'timetrap configured',
    'git.managed',
    'libqt4 installed',
    'libv8 installed',

    # Language environments
    'ruby environment'
    # 'nodejs environment',
    # 'pyhton environment',
    # 'closure environment'
  ]
}
