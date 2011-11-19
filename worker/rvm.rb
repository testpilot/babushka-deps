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
        log_block("Installing Ruby #{ruby}") {
          login_shell "#{rvm} install #{ruby}", :spinner => true
        }
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

  template {
    met? {
      rubies.all? do |ruby|
        login_shell("#{rvm} use #{ruby}; find $GEM_HOME/gems -name \"#{name}-[0-9]*.[0-9]*.[0-9]*\" | grep #{name}") {|s| s.stdout.chomp if s.ok? }
      end
    }

    meet {
      rubies.each do |ruby|
        log_block "Installing #{name} for #{ruby}" do
          versions.each do |version|
            log_block "Version #{version}" do
              login_shell "#{rvm} use #{ruby}; gem install #{name} --no-ri --no-rdoc", :log => true
            end
          end
        end
      end
    }
  }
end

# dep('bundler.global_gem') {
#   rubies '1.9.2', '1.8.7', '1.9.3'
#   versions '1.0.12', '1.1.pre'
# }
#
# dep('rake.global_gem') {
#   rubies '1.9.2', '1.8.7', '1.9.3'
#   versions '0.8.7', '0.9.2'
# }
#
# dep('rails.global_gem') {
#   rubies '1.9.2', '1.8.7', '1.9.3'
#   versions '3.0.12', '3.1.2'
# }
#
# dep('popular gems installed'){
#   requires 'bundler.global_gem', 'rake.global_gem', 'rails.global_gem'
# }

dep('libgdbm-dev.managed') { provides [] }
dep('libreadline5-dev.managed') { provides [] }
dep('libssl-dev.managed') { provides [] }
dep('libxml2-dev.managed') { provides [] }
dep('libxslt1-dev.managed') { provides [] }
dep('zlib1g-dev.managed') { provides [] }
