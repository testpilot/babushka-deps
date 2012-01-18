dep('sphinx multiple versions installed') {
  requires 'sphinx installed'.with('2.0.1-beta'),
           'sphinx installed'.with('1.10-beta'),
           'sphinx installed'.with('sphinx-0.9.9'),
           'sphinx binaries linked'.with('2.0.1-beta')
}

dep('libmysql++-dev.managed') { provides [] }

dep('sphinx installed', :version) {
  version.default!('2.0.1-beta')

  requires 'libmysql++-dev.managed'

  def sphinx_src_path
    "http://www.sphinxsearch.com/files/sphinx-#{version}.tar.gz"
  end

  def path
    '/usr/local' / "sphinx-#{version}"
  end

  met? { path.exists? }

  meet {
    # Download and extract, entering new directory
    Babushka::Resource.extract(sphinx_src_path) do
      # Download libstemmer_c and copy to here
      Babushka::Resource.get('http://snowball.tartarus.org/dist/libstemmer_c.tgz') do |download_path|
        shell "cp #{download_path} ./"
        shell "tar zxvf libstemmer_c.tgz"
      end

      log_shell "Configuring Sphinx #{version} with stemmer support for installation into #{path}", "./configure --with-mysql --with-pgsql --with-libstemmer --prefix=#{path}"
      log_shell "Compiling Sphinx", "make"
      log_shell "Installing", "sudo make install"
    end
  }
}

dep('sphinx binaries linked', :version) {
  version.default!('2.0.1-beta')

  def path
    '/usr/local' / "sphinx-#{version}"
  end

  def binaries
    %w( indexer indextool search searchd spelldump )
  end

  def binary_path(binary)
    path / 'bin' / binary
  end

  met? {
    binaries.all? { |binary| binary_path(binary).exists? }
  }

  meet {
    binaries.each do |binary|
      log_shell "Linking #{binary}", "sudo ln -s #{binary_path(binary)} /usr/local/bin/#{binary}"
    end
  }
}
