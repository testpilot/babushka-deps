dep('firefox installed') {
  requires 'firefox.managed'
}

# sudo add-apt-repository ppa:mozillateam/firefox-stable
# 
# sudo apt-get update
# sudo apt-get upgrade

dep('firefox.managed') {
  before {
    shell "sudo add-apt-repository ppa:mozillateam/firefox-stable"
    shell "sudo apt-get update"
  }
  installs { via :apt, 'firefox' }
  after {
    shell "sudo apt-get upgrade firefox"
  }
}
