dep("phantom.js installed") {
  requires  'libfreetype6-dev.managed',
            'libfreetype6.managed',
            'fontconfig.managed',
            'chrpath.managed',
            'libssl-dev.managed',
            'libfontconfig1-dev.managed'

  met? { in_path?("phantomjs") }

  before {
    shell "rm -rf /tmp/phantomjs"
  }

  meet {
    # sudo apt-get install build-essential chrpath git-core libssl-dev libfontconfig1-dev
    # git clone git://github.com/ariya/phantomjs.git && cd phantomjs
    # git checkout 1.5
    # ./build.sh

    log_shell "Cloning Phantom.js", "git clone git://github.com/ariya/phantomjs.git /tmp/phantomjs/" and
    log_shell "Checkout Version 1.5", "cd /tmp/phantomjs && git checkout 1.5" and
    log_shell "Building Phantom.js", "cd /tmp/phantomjs/ && ./build.sh"
  }
}

dep('libfreetype6.managed') { provides [] }
dep('libfreetype6-dev.managed') { provides [] }
dep('fontconfig.managed') { provides [] }
dep('chrpath.managed') 
dep('chrpath.managed')
dep('libssl-dev.managed') { provides [] }
dep('libfontconfig1-dev.managed') { provides [] }
