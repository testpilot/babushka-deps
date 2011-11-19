dep('ruby environment', :global_ruby_versions){
  requires [
    'required.rubies_installed'.with(global_ruby_versions),
    'bundler.global_gem'.with(global_ruby_versions),
    'rake.global_gem'.with(global_ruby_versions),
    'rails.global_gem'.with(global_ruby_versions)
  ]
}

dep('required.rubies_installed', :ruby_versions) {
  rubies *ruby_versions.to_s.split(',').map(&:chomp)
}

dep('bundler.global_gem', :ruby_versions) {
  rubies *ruby_versions.to_s.split(',').map(&:chomp)
  versions '1.0.12', '1.1.pre'
}

dep('rake.global_gem', :ruby_versions) {
  rubies *ruby_versions.to_s.split(',').map(&:chomp)
  versions '0.8.7', '0.9.2'
}

dep('rails.global_gem', :ruby_versions) {
  rubies *ruby_versions.to_s.split(',').map(&:chomp)
  versions '2.1.2', '2.2.3', '2.3.14', '3.0.0', '3.0.1', '3.0.2', '3.0.3', '3.0.4', '3.0.5', '3.0.6', '3.0.7', '3.0.8', '3.0.9', '3.0.10', '3.1.0', '3.1.1', '3.1.2'
}

dep('therubyracer.global_gem') {
  rubies *ruby_versions.to_s.split(',').map(&:chomp)
  versions '0.9.3', '0.9.4', '0.9.5', '0.9.6', '0.9.7', '0.9.8'
}
