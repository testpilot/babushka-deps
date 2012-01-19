dep('rvm with multiple rubies'){
  requires 'ruby dependencies', 'rvm installed'
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

  def user
    shell('whoami').strip
  end

  met? { "/home/#{user}/.rvm".p.directory? }
  meet {
    Babushka::Resource.get('https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer') do |download_path|
      shell "chmod +x #{download_path}"
      shell "#{download_path} --version #{var(:version)}"
    end

    render_erb("rvm/rvm.sh.erb", :to => "/etc/profile.d/rvm.sh", :sudo => true)
    render_erb("rvm/dot_rvmrc.erb", :to => "/home/#{user}/.rvmrc", :sudo => false)
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
  accepts_list_for :rubies, ['1.8.7', '1.9.2', '1.9.3']
  accepts_list_for :skipped_versions, []
  accepts_value_for :depth, 1

  def gem_name
    name.split('.').first
  end

  def home
    ENV['HOME']
  end

  def user
    shell('whoami').strip
  end

  def rvm
    "source #{home}/.rvm/scripts/rvm && rvm"
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

  def versions
    load_gem_version_data(gem_name).reject {|version| skipped_versions.include?(version) }[0, depth]
  end

  def load_gem_version_data(gem_name)
    begin
      require "rubygems"
      require "json"
      require "net/http"
    rescue LoadError
      log "Failed to load gems for version lookup"
      log_shell("Installing json", "bash -l -c '#{rvm} use default; gem install json --no-ri --no-rdoc'", :spinner => true) && retry
    end
    @versions ||= begin
      puts "---> Fetching gem versions for #{gem_name}"

      # Load gem versions from rubygems.org API
      gem_versions = JSON.parse(Net::HTTP.get("rubygems.org", "/api/v1/versions/#{gem_name}.json")).
        # Skip prerelease gems
        select {|gem| gem['prerelease'] == false }.
        # Restrict to MRI
        select {|gem| gem['platform'] == 'ruby' }.
        map {|gem| gem['number'] }.sort
    end
  end

  def installed_versions
    all_mutations.select do |mutation|
      shell?("bash -l -c '#{rvm} use #{mutation[:ruby]}; find $GEM_HOME/gems -name \"#{mutation[:name]}-#{mutation[:version]}*\" | grep #{mutation[:name]}'")
    end
  end

  def missing_versions
    all_mutations - installed_versions
  end

  template do
    met? {
      missing_versions.empty?
    }

    meet {
      log_info "Missing #{gem_name} #{missing_versions.join(', ')}"
      missing_versions.each do |mutation|
        log_shell "Installing #{mutation[:name]} version #{mutation[:version]} for #{mutation[:ruby]}", "bash -l -c '#{rvm} use #{mutation[:ruby]}; gem install #{mutation[:name]} --no-ri --no-rdoc --version #{mutation[:version]}'", :spinner => true
      end
    }

    after {
      @versions = nil
    }
  end
end

# meta(:all_versions) {
#   accepts_list_for :gems
# 
#   template {
#     met? {
# 
#     }
# 
#     meet {
# 
#     }
#   }
# }

dep('libgdbm-dev.managed') { provides [] }
dep('libreadline5-dev.managed') { provides [] }
dep('libssl-dev.managed') { provides [] }
dep('libxml2-dev.managed') { provides [] }
dep('libxslt1-dev.managed') { provides [] }
dep('zlib1g-dev.managed') { provides [] }
