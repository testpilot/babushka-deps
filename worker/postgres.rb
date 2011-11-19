dep('postgresql installed'){
  requires 'postgres.managed'
}

dep 'postgres.managed', :version do
  version.default('9.1')
  requires {
    on :apt, 'set.locale', 'postgres.ppa'
    on :brew, 'set.locale'
  }
  installs {
    via :apt, ["postgresql-#{owner.version}", "libpq-dev"]
    via :brew, "postgresql"
  }
  provides "psql ~> #{version}.0"
end

dep 'postgres access' do
  requires 'postgres.managed', 'user exists'
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{var :username}\b/).empty? }
  meet { sudo "createuser -SdR #{var :username}", :as => 'postgres' }
end

dep 'pg.gem' do
  requires 'postgres.managed'
  provides []
end

dep 'postgres.ppa' do
  adds 'ppa:pitti/postgresql'
end
