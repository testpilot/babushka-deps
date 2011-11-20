dep('rvm with multiple rubies'){
  requires 'ruby dependencies', 'rvm installed', 'required.rubies_installed'
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

meta :rubies_installed do
  accepts_list_for :rubies

  def home
    ENV['HOME']
  end

  def user
    shell('whoami').strip
  end

  def rvm
    "source #{home}/.rvm/scripts/rvm && rvm"
  end

  template {
    met? {
      rubies.all? { |ruby|
        shell?("ls #{home}/.rvm/rubies | grep #{ruby}")
      }
    }

    meet {
      set :rvm_user_install_flag, 1

      rubies.each do |ruby|
        log_shell "Installing Ruby #{ruby}", "bash -l -c '#{rvm} install #{ruby}'", :spinner => true
      end

      login_shell "#{rvm} --default #{rubies.first}"
    }

    after {
      login_shell "#{rvm} cleanup all"
    }
  }
end

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

meta :global_gem do
  accepts_list_for :rubies
  accepts_list_for :versions

  def home
    ENV['HOME']
  end

  def user
    shell('whoami').strip
  end

  def rvm
    "source #{home}/.rvm/scripts/rvm && rvm"
  end

  def gem_name
    name.split('.').first
  end

  def all_mutations
    mutations = []
    rubies.each { |ruby|
      versions.each { |version|
        mutations << {:ruby => ruby, :version => version, :name => gem_name}
      }
    }
    mutations
  end

  def dep_for_mutation(mutation)
    "#{mutation[:name]} #{mutation[:version]} .gem"
  end

  template {
    met? {
      rubies.all? { |ruby|
        versions.all? { |version|
          log "Checking if #{gem_name} version #{version} for #{ruby} is installed"
          shell?("bash -l -c '#{rvm} use #{ruby}; find $GEM_HOME/gems -name \"#{gem_name}-#{version}*\" | grep #{gem_name}'")
        }
      }
    }

    meet {
      rubies.each do |ruby|
        versions.each do |version|
          log_shell "Installing #{gem_name} version #{version} for #{ruby}", "bash -l -c '#{rvm} use #{ruby}; gem install #{gem_name} --no-ri --no-rdoc --version #{version}'", :spinner => true
        end
      end
    }
  }
end

meta :gem_installed do
  accepts_value_for :version
  accepts_value_for :ruby

  template {

  }
end

dep('libgdbm-dev.managed') { provides [] }
dep('libreadline5-dev.managed') { provides [] }
dep('libssl-dev.managed') { provides [] }
dep('libxml2-dev.managed') { provides [] }
dep('libxslt1-dev.managed') { provides [] }
dep('zlib1g-dev.managed') { provides [] }
