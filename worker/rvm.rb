dep('rvm with multiple rubies'){
  requires 'ruby dependencies', 'rvm installed',
    'rvm ruby installed'.with('1.9.2'),
    'rvm ruby installed'.with('1.9.3'),
    'rvm default ruby set'.with('1.9.2')
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
      shell "#{download_path} --version #{var(:version)}"
    end

    render_erb("rvm/rvm.sh.erb", :to => "/etc/profile.d/rvm.sh", :sudo => true)
    render_erb("rvm/dot_rvmrc.erb", :to => "~/.rvmrc", :sudo => false)
  }
}

def home
  ENV['HOME']
end

def user
  shell('whoami').strip
end

def rvm
  "source #{home}/.rvm/scripts/rvm && rvm"
end

dep('rvm ruby installed', :ruby) {
  met? { shell?("ls #{home}/.rvm/rubies | grep #{ruby}") }

  meet {
    env  = { 'rvm_user_install_flag' => '1' }

    env.each do |k,v|
      # shell "export #{k.to_s}=#{v}"
      # ENV[k] = v
      set k, v
    end

    login_shell "#{rvm} install #{ruby}", :spinner => true
  }
}

dep('rvm default ruby set', :version) {
  met? { false }

  meet {
    login_shell "#{rvm} --default #{version}"
  }
}

dep('popular gems installed', :rubies){

}

dep('libgdbm-dev.managed') { provides [] }
dep('libreadline5-dev.managed') { provides [] }
dep('libssl-dev.managed') { provides [] }
dep('libxml2-dev.managed') { provides [] }
dep('libxslt1-dev.managed') { provides [] }
dep('zlib1g-dev.managed') { provides [] }
