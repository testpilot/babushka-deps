dep('test environment') {
  requires [
    'ubuntu user exists',
    'language-pack-en.managed',
    'set.locale',
    'core dependencies',
    'build essential installed',
    'python build environment',
    'yaml configured',
    'timetrap configured',
    'java installed',
    'git.managed',
    'libqt4 installed',
    'libv8 installed',
    'nodejs multi installed',
    'imagemagick.managed',
    'xvfb installed',
    'firefox installed',
    'workspace setup',

    # Databases
    'sqlite installed',
    'postgresql installed',
    'mysql installed',
    'redis installed',
    'riak installed',
    'mongodb installed',

    # Sphinx Search
    'sphinx multiple versions installed',

    # Language environments
    'ruby environment'.with('1.8.7, 1.9.2, 1.9.3, ruby-head, ree, jruby, rbx, rbx-2.0.0pre'),

    'ensure workspace is writeable and clean'
  ]
}
