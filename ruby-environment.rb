rubies = ['1.8.7', '1.9.2', '1.9.3']

dep('ruby environment'){
  requires [
    'required.rubies_installed'.with(rubies),
    'bundler.global_gem'.with(rubies),
    'rake.global_gem'.with(rubies),
    'rails.global_gem'.with(rubies)
  ]
}

dep('bundler.global_gem') {
  versions '1.0.12', '1.1.pre'
}

dep('rake.global_gem') {
  versions '0.8.7', '0.9.2'
}

dep('rails.global_gem') {
  versions '3.0.12', '3.1.2'
}
