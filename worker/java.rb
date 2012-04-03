dep('ant installed') {
  requires 'ant.managed', 'ant-contrib.managed', 'ivy.managed'
}

dep('java installed') {
  requires 'java.managed'
}

dep 'java.managed' do
  installs { via :apt, 'openjdk-6-jdk' }
end
