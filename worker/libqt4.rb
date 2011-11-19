dep('libqt4 installed'){
  requires 'libqt4.apt_source', 'libqt4.managed'
}

dep('libqt4.apt_source') {
  source_name 'kubuntu-backports-ppa-deb'
}

dep('libqt4-src.apt_source') {
  source_name 'kubuntu-backports-ppa-deb-src'

dep('libqt4.managed') {
  installs via :apt, 'qt4-qmake', 'libqt4-dev'
}

