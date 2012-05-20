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
    #

    in_build_dir {
      log_shell "Cloning Phantom.js", "git clone git://github.com/ariya/phantomjs.git phantomjs" and
      cd('./phantomjs') {
        log_shell "Checkout Version 1.5", "git checkout 1.5" and
        log_shell "Building Phantom.js", "./build.sh" and
        log_shell "Packaging Phantom.js", "./deploy/package-linux-dynamic.sh" and
        log_shell "Extracting phantom.js build", "tar -xzf phantomjs.tar.gz" and
        log_shell "Installing Phantom.js", "cp -rf ./phantomjs /usr/local/", :sudo => true and
        log_shell "Copying phantomjs binary to /usr/local/bin/",
          "ln -s /usr/local/phantomjs/bin/phantomjs /usr/local/bin/phantomjs", :sudo => true

      }
    }

  }
}

dep('libfreetype6.managed') { provides [] }
dep('libfreetype6-dev.managed') { provides [] }
dep('fontconfig.managed') { provides [] }
dep('chrpath.managed')
dep('chrpath.managed')
dep('libssl-dev.managed') { provides [] }
dep('libfontconfig1-dev.managed') { provides [] }
