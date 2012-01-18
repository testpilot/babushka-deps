dep('ant installed') {
  requires 'ant.managed', 'ant-contrib.managed', 'ivy.managed'
}

dep('java installed') {
  requires 'java license accepted', 'java.managed'
}

dep('java license accepted') {
  met? {
    shell?("debconf-show sun-java5-jdk | grep \"shared/accepted\"", :sudo => true) and
    shell?("debconf-show sun-java5-jre | grep \"shared/accepted\"", :sudo => true) and
    shell?("debconf-show sun-java6-jdk | grep \"shared/accepted\"", :sudo => true) and
    shell?("debconf-show sun-java6-jre | grep \"shared/accepted\"", :sudo => true)
  }

  meet {
    # shell "sudo debconf 'echo SET shared/accepted-sun-dlj-v1-1 true; echo $(read) >&2'"
    shell("echo sun-java5-jdk shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections", :sudo => true) and
    shell("echo sun-java5-jre shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections", :sudo => true) and
    shell("echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections", :sudo => true) and
    shell("echo sun-java6-jre shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections", :sudo => true)
  }
}

dep 'java.managed' do
  before {
    shell "add-apt-repository \"deb http://archive.canonical.com/ lucid partner\"", :sudo => true
    Babushka::AptHelper.update_pkg_lists
  }
  installs { via :apt, 'sun-java6-jre' }
  # after { shell "set -Ux JAVA_HOME /usr/lib/jvm/java-6-sun" }
end
