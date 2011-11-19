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
      if key
        require 'babushka/resource'
        
        Resource.get key do |path|
          shell "apt-key add #{path}"
        end
      end

      [name, source].compact.each do |name|
        append_to_file "#{source == name ? 'deb-src' : 'deb'} #{uri} #{Babushka::Base.host.name} #{name}", '/etc/apt/sources.list', :sudo => true
      end
    }
    after { Babushka::AptHelper.update_pkg_lists }
  }
end
