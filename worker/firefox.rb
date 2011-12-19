dep('firefox installed') {
  requires 'firefox.managed'
}

dep('firefox.managed') {
  before {
    shell "sudo add-apt-repository ppa:mozillateam/firefox-stable"
    shell "sudo apt-get update"
  }
  installs { via :apt, 'firefox' }
}
