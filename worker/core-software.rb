packages = [
  'lsof',
  'iptables',
  'jwhois',
  'whois',
  'curl',
  'wget',
  'rsync',
  'jnettop',
  'nmap',
  'traceroute',
  'ethtool',
  'tcpdump',
  'elinks',
  'lynx'
].each do |package|
  dep [package, 'managed'].join('.')
end

packages_without_binary = [
  'iputils-ping',
  'netcat-openbsd',
  'bind9-host',
  'libreadline5-dev',
  'libssl-dev',
  'libxml2-dev',
  'libxslt1-dev',
  'zlib1g-dev'
].each { |p|
  dep [p, 'managed'].join('.') { provides [] }
}

dep('core dependencies') {
  requires (packages + packages_without_binary).map { |p| "#{p}.managed" }
}

