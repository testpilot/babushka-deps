dep('riak installed') {
  requires 'riak installed from package'
}

dep('riak installed from package'){
  met? {
    shell?('which riak')
  }

  meet {
    Babushka::Resource.get('http://downloads.basho.com.s3-website-us-east-1.amazonaws.com/riak/1.0/1.0.0/riak_1.0.0-1_i386.deb') do |download_path|
      log_shell("Installing Riak", "dpkg -i #{download_path}", :log => true, :sudo => true)
    end
  }
}
