dep('ant installed') {
  requires 'ant.managed', 'ant-contrib.managed', 'ivy.managed'
}

dep('java installed') {
  requires 'java.managed'
}

dep 'java.managed' do
  before {
    shell "add-apt-repository \"deb http://archive.canonical.com/ lucid partner\"", :sudo => true
    Babushka::AptHelper.update_pkg_lists
  }
  installs { via :apt, 'sun-java6-jre' }
  after { shell "set -Ux JAVA_HOME /usr/lib/jvm/java-6-sun" }
end
