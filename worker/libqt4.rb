dep('libqt4 installed'){
  requires 'libqt4.apt_repository', 'libqt4.managed'
}

dep('libqt4.apt_repository') {
  name 'main'
  source true
  uri 'http://ppa.launchpad.net/kubuntu-ppa/backports/ubuntu'
  key 'https://raw.github.com/gist/1208649/51c907099ec6f2003c6e120621f069c3cd1a75e6/gistfile1.txt'
}

dep('libqt4.managed') {
  installs { via :apt, 'qt4-qmake', 'libqt4-dev' }
}
