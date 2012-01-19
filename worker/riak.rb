dep('riak installed') {
  requires 'riak installed from package'
}

dep('riak installed from package'){
  met? {
    shell?('which riak')
  }

  meet {
    if shell?("uname -m | grep x86_64")
      # We're 64bit baby!
      Babushka::Resource.get('http://downloads.basho.com/riak/riak-1.0.2/riak_1.0.2-1_amd64.deb') do |download_path|
        log_shell("Installing Riak", "dpkg -i #{download_path}", :log => true, :sudo => true)
      end
    else
      Babushka::Resource.get('http://downloads.basho.com/riak/riak-1.0.2/riak_1.0.2-1_i386.deb') do |download_path|
        log_shell("Installing Riak", "dpkg -i #{download_path}", :log => true, :sudo => true)
      end
    end
  }
}
