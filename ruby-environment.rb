dep('ruby environment', :global_ruby_versions){
  requires [
    'required.rubies_installed'.with(global_ruby_versions),
    'bundler.global_gem'.with(global_ruby_versions),
    'rake.global_gem'.with(global_ruby_versions),
    'rails.global_gem'.with(global_ruby_versions)
  ]
}

dep('bundler.global_gem', :ruby_versions) {
  rubies ruby_versions.to_s.split(',').map(&:chomp)
  versions '1.0.12', '1.1.pre'
}

dep('rake.global_gem', :ruby_versions) {
  rubies ruby_versions.to_s.split(',').map(&:chomp)
  versions '0.8.7', '0.9.2'
}

dep('rails.global_gem', :ruby_versions) {
  rubies ruby_versions.to_s.split(',').map(&:chomp)
  versions '3.0.12', '3.1.2'
}

dep('required.rubies_installed', :ruby_versions) {
  rubies ruby_versions.to_s.split(',').map(&:chomp)
}
