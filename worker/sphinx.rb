dep('sphinx multiple versions installed') {
  requires 'sphinx installed'.with('2.0.1-beta'), 'sphinx installed'.with('1.10-beta', 'sphinx installed'.with('sphinx 0.9.9'
}

dep('libmysql++-dev.managed') { provides [] }

dep('sphinx installed', :version) {
  requires 'libmysql++-dev.managed'
  
  def tmp_install_dir
    '/tmp' / 'sphinx_install'
  end
  
  def sphinx_src_path
    "http://www.sphinxsearch.com/files/sphinx-#{version}.tar.gz"
  end
  
  met? {
    false
  }
  
  meet {
    # shell "mkdir -p #{tmp_install_dir} && cd #{tmp_install_dir}"
    Babushka::Resource.extract(sphinx_src_path) do |download_path|
      puts download_path
    end
    # cp libstemmer_c.tgz sphinx-#{version}/libstemmer_c.tgz
    # cd sphinx-#{version}
    # tar zxvf libstemmer_c.tgz
    # ./configure --with-mysql --with-pgsql --with-libstemmer --prefix=#{path} 
    # make && make install
    # 
  }
}

# dep('libstemmer installed once') {
#   meet {
#     Babushka::Resource.get('http://snowball.tartarus.org/dist/libstemmer_c.tgz') do |download_path|
#       log_shell("Installing Riak", "dpkg -i #{download_path}", :log => true, :sudo => true)
#     end
#   }
# }