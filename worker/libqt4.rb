meta :apt_repository do
  accepts_value_for :name
  accepts_value_for :uri
  accepts_value_for :key
  accepts_value_for :source

  template {
    met? {
      grep(/^deb .* #{Babushka::Base.host.name} (\w+ )*#{Regexp.escape(name)}/, '/etc/apt/sources.list')
    }
    before {
      # Don't edit sources.list unless we know how to edit it for this debian flavour and version.
      Babushka::AptHelper.source_for_system and Babushka::Base.host.name
    }
    meet {
      shell "gpg --keyserver subkeys.pgp.net --recv-keys #{key}"
      shell "gpg --armor --export #{key} | sudo apt-key add -"

      [name, source].compact.each do |name|
        append_to_file "#{source == name ? 'deb-src' : deb} #{uri} #{Babushka::Base.host.name} #{name}", '/etc/apt/sources.list', :sudo => true
      end
    }
    after { Babushka::AptHelper.update_pkg_lists }
  }
end

dep('libqt4 installed'){
  requires 'libqt4.apt_source', 'libqt4.managed'
}

dep('libqt4.apt_repository') {
  name 'kubuntu-backports-ppa-deb'
  source 'kubuntu-backports-ppa-deb-src'
  uri 'http://ppa.launchpad.net/kubuntu-ppa/backports/ubuntu'
  key 'https://raw.github.com/gist/1208649/51c907099ec6f2003c6e120621f069c3cd1a75e6/gistfile1.txt'
}

dep('libqt4.managed') {
  installs { via :apt, 'qt4-qmake', 'libqt4-dev' }
}
