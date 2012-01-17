dep('ruby environment', :global_ruby_versions){
  requires [
    'rvm with multiple rubies',
    'required.rubies_installed'.with(global_ruby_versions),
    'latest versions of popular gems'
  ]
}

dep('required.rubies_installed', :ruby_versions) {
  rubies *ruby_versions.to_s.split(',').map(&:chomp)
}

# This automatically installs the last 10 versions of popular gems
# in order to speed up ruby dependency installation.

# Wrap everything in a lambda so that we can lazily load it later
# (This process currently doesn't work due to the way babs works)
# We can probably just lazily eval the version lookup later.
#
load_gems = lambda {
  require "rubygems"
  require 'json'
  require 'net/http'

  # Create an array of common gems which can be added to later very easily.
  # The syntax is gemname:<array start index>,<array end index>
  #
  # Basically the API call to rubygems below returns an array of version numbers,
  # and because some of these are just way too outdated to be useful we might only want
  # to install the last 5 or 10 releases, which is what the numbers are the : are restricting.
  #
  # e.g. rails:0,5 will return rails 3.1.2, 3.1.1, 3.1.0, 3.0.11, 3.0.10
  #
  gems = %w(
  typhoeus
  pg
  mysql2
  sqlite3
  gherkin
  nokogiri
  therubyracer
  rails
  rake
  bundler
  timecop
  shoulda
  rdoc
  newgem
  rubigen
  metaclass
  json
  iron_mq
  rest-client
  multi_json
  faraday
  faraday_middleware
  airbrake
  validates_timeliness
  unicorn
  uglifier
  timeliness
  thin
  state_machine
  simple_form
  sass-rails
  resque
  sinatra
  minitest
  minitest-matchers
  ruby-progressbar
  mongrel
  kaminari
  jquery-rails:0,2
  inherited_resources
  responders
  heroku
  eventmachine:0,3
  delorean
  journey:0,1
  ).reverse

  # Returns an array of dep names
  gem_requires = gems.map do |gem_name|
    puts "---> Fetching gem versions for #{gem_name}"

    # Split gem name on :
    if gem_name.include?(':')
      version_range = gem_name.split(':',2).last.split(',').map(&:strip).map(&:to_i)
      gem_name = gem_name.split(':').first
    else
      # If no version range was supplied in the name, default here.
      version_range = [0,10]
    end

    # Load gem versions from rubygems.org API
    gem_versions = JSON.parse(Net::HTTP.get("rubygems.org", "/api/v1/versions/#{gem_name}.json")).
      select {|gem| gem['prerelease'] == false }.
      select {|gem| gem['platform'] == 'ruby' }.
      map {|gem| gem['number']}

    gem_versions = gem_versions[*version_range]

    unless gem_versions.empty?
      dep("#{gem_name}.global_gem") {
        # Install for MRI only at this stage
        # TODO: Use rubygems designated platform for ruby VM
        # e.g. ruby = MRI, jruby = JRUBY
        rubies *%w(1.8.7 1.9.2 1.9.3)
        # Pass gem versions array to dep argument
        versions *gem_versions
      }
      puts "     Defined dep '#{gem_name}.global_gem'"
    end
    # Return dep name
    "#{gem_name}.global_gem"
  end

  gem_requires
}

# Eval gem lambda
gem_deps = instance_eval(&load_gems)

# Create a dep which requires all of the above.
dep('latest versions of popular gems'){
  requires gem_deps
}

