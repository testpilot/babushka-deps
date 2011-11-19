dep('rvm with multiple rubies'){
  define_var :rubies, :default => ['1.9.2']
  requires 'ruby dependencies', 'rvm installed', 'rvm rubies installed'.with(rubies)
}

dep('ruby dependencies'){
  requires [
    'libgdbm-dev.managed',
    'libreadline5-dev.managed',
    'libssl-dev.managed',
    'libxml2-dev.managed',
    'libxslt1-dev.managed',
    'zlib1g-dev.managed'
  ]

}

dep('rvm installed') {
  define_var :version, :default => "1.9.2"

  met? { "/home/ubuntu/.rvm".p.directory? }
  meet {
    Babushka::Resource.get('https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer') do |download_path|
      shell "chmod +x #{download_path}"
      shell "rvm-installer --version #{var(:version)}"
    end

    render_erb("rvm/rvm.sh.erb", :to => "/etc/profile.d/rvm.sh", :sudo => false)
    render_erb("rvm/dot_rvmrc.erb", :to => "~/.rvmrc", :sudo => false)
  }
}

dep('rvm rubies installed') {
  requires var(:rubies).map { |ruby| 'rvm ruby installed'.with(ruby) }
}

dep('rvm ruby installed', :ruby) {
  def home
    ENV['HOME']
  end

  def user
    shell('whoami').strip
  end

  met? {
    shell("ls #{home}/.rvm/rubies | grep #{ruby}")
  }

  meet {
    rvm  = "source #{home}/.rvm/scripts/rvm && rvm"
    env  = { 'rvm_user_install_flag' => '1' }

    env.each do |k,v|
      shell "export #{k.to_s}=#{v}"
    end

    shell "#{rvm} install #{ruby}"
  }
}

dep('popular gems installed', :rubies){

}

dep('libgdbm-dev.managed')
dep('libreadline5-dev.managed')
dep('libssl-dev.managed')
dep('libxml2-dev.managed')
dep('libxslt1-dev.managed')
dep('zlib1g-dev.managed')
