dep('sphinx multiple versions installed') {
  requires 'sphinx installed'.with('2.0.1-beta'), 'sphinx installed'.with('1.10-beta'), 'sphinx installed'.with('sphinx 0.9.9')
}

dep('libmysql++-dev.managed') { provides [] }

dep('sphinx installed', :version) {
  requires 'libmysql++-dev.managed'
  
  def sphinx_src_path
    "http://www.sphinxsearch.com/files/sphinx-#{version}.tar.gz"
  end
  
  def path
    '/usr/local' / version
  end
  
  met? {
    false
  }
  
  meet {
    # Download and extract, entering new directory
    Babushka::Resource.extract(sphinx_src_path) do
      # Download libstemmer_c and copy to here
      Babushka::Resource.get('http://snowball.tartarus.org/dist/libstemmer_c.tgz') do |download_path|
        shell "cp #{download_path} ./"
        shell "tar zxvf libstemmer_c.tgz"
      end
    
      log "Sphinx directory is: #{shell('pwd')}"
    
      log_shell "Configuring Sphinx #{version} with stemmer support for installation into #{path}", "./configure --with-mysql --with-pgsql --with-libstemmer --prefix=#{path}"
      log_shell "Compiling Sphinx", "make && make install", :sudo => true
    end
  }
}
