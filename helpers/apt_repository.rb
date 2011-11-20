meta :apt_repository do
  accepts_value_for :repo_name
  accepts_value_for :source
  accepts_value_for :uri
  accepts_value_for :key
  accepts_value_for :distro, :host

  def host
    Babushka::Base.host.name
  end

  template {
    met? {
      grep(/^deb #{Regexp.escape(uri)} #{distro} (\w+ )*#{Regexp.escape(repo_name)}/, '/etc/apt/sources.list')
    }
    before {
      # Don't edit sources.list unless we know how to edit it for this debian flavour and version.
      Babushka::AptHelper.source_for_system and Babushka::Base.host.name
    }
    meet {
      if key
        Babushka::Resource.get key do |path|
          shell "apt-key add #{path}", :sudo => true
        end
      end

      self.repo_name ||= 'main'

      append_to_file "deb #{uri} #{distro} #{repo_name}", '/etc/apt/sources.list', :sudo => true
      append_to_file "deb-src #{uri} #{distro} #{repo_name}", '/etc/apt/sources.list', :sudo => true if source.eql?(true)
    }
    after { Babushka::AptHelper.update_pkg_lists }
  }
end
