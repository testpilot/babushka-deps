dep('ant installed') {
  requires 'ant.managed', 'ant-contrib.managed', 'ivy.managed'
}

dep('java installed') {
  requires 'openjdk-6-jdk.managed', 'default-jdk.managed'

  met? {}

  meet {
    shell "update-java-alternatives -s java-6-openjdk"
  }
}