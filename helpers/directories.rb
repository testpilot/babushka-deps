meta(:directories) do
  accepts_list_for :directories
  accepts_value_for :owner
  accepts_value_for :perms

  template {
    met? {
      directories.map(&:p).all? do |dir|
        dir.exists?
      end
    }

    meet {
      directories.each do |dir|
        log_shell "Creating directory: #{dir}", "mkdir -p #{dir}", :sudo => true
        shell "chown #{owner}:#{owner} #{dir}", :sudo => true
        shell "chmod #{perms} -R #{dir}", :sudo => true if perms
      end
    }
  }
end
