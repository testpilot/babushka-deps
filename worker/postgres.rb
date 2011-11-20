dep('postgresql installed'){
  requires 'postgres.managed', 'postgres configured'
}

dep 'postgres.managed', :version do
  # version.default('9.1')
  define_var(:version, :default => '9.1')

  requires {
    on :apt, 'set.locale', 'postgres.ppa'
    on :brew, 'set.locale'
  }
  installs {
    via :apt, ["postgresql-#{owner.version}", "libpq-dev", 'postgresql-client']
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

dep('postgres configured', :version) {
  # version.default('9.1')
  define_var(:version, :default => '9.1')

  def postgres_dir
    "/etc/postgresql/#{version}/main"
  end

  def max_connections
    255
  end

  met? {
    babushka_config?(postgres_dir / 'pg_hba.conf') &&
    babushka_config?(postgres_dir / 'postgresql.conf')
  }

  meet {
    shell("mv -f #{postgres_dir / 'pg_hba.conf'}{,.orig}", :sudo => true)
    shell("mv -f #{postgres_dir / 'postgresql.conf'}{,.orig}", :sudo => true)

    render_erb("postgres/pg_hba.conf.erb", :to => postgres_dir / 'pg_hba.conf', :sudo => true)
    render_erb("postgres/postgresql.conf.erb", :to => postgres_dir / 'postgresql.conf', :sudo => true)

    shell("chmod 0600 #{postgres_dir / 'pg_hba.conf'}", :sudo => true)
    shell("chown postgres:postgres #{postgres_dir / 'pg_hba.conf'}", :sudo => true)

    shell("chmod 0600 #{postgres_dir / 'postgresql.conf'}", :sudo => true)
    shell("chown postgres:postgres #{postgres_dir / 'postgresql.conf'}", :sudo => true)
  }

  after {
    log_shell "Restarting postgres", "service postgresql restart", :sudo => true
  }
}


