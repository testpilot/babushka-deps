dep('timetrap configured') {
  met? {
    "/usr/local/bin/timetrap".exists? &&
    "/etc/profile.d/timetrap.sh".exists?
  }
  meet {
    render_erb("timetrap/timetrap.erb", :to => "/usr/local/bin/timetrap", :sudo => true)
    render_erb("timetrap/timetrap_environment.sh.erb", :to => "/etc/profile.d/timetrap.sh", :sudo => true)
    shell "chmod a+x /usr/local/bin/timetrap", :sudo => true
  }
}
