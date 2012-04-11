dep 'deploy repo', :path do
  requires [
    'web repo exists'.with(path),
    'web repo hooks'.with(path),
    'web repo always receives'.with(path),
    'bundler.gem'
  ]
  met? {
    vanity_path = path.p.sub(/^#{Etc.getpwuid(Process.euid).dir.chomp('/')}/, '~')
    log "All done. The repo's URI: " + "#{shell('whoami')}@#{shell('hostname -f')}:#{vanity_path}".colorize('underline')
    true
  }
end

dep 'web repo always receives', :path do
  requires 'web repo exists'.with(path)
  met? { cd(path) { shell?("git config receive.denyCurrentBranch") == 'ignore' } }
  meet { cd(path) { shell("git config receive.denyCurrentBranch ignore") } }
end

dep 'web repo hooks', :path do
  requires 'web repo exists'.with(path)
  met? {
    %w[pre-receive post-receive].all? {|hook_name|
      (path / ".git/hooks/#{hook_name}").executable? &&
      Babushka::Renderable.new(path / ".git/hooks/#{hook_name}").from?(dependency.load_path.parent / "git/deploy-repo-#{hook_name}")
    }
  }
  meet {
    cd path, :create => true do
      %w[pre-receive post-receive].each {|hook_name|
        render_erb "git/deploy-repo-#{hook_name}", :to => ".git/hooks/#{hook_name}"
        shell "chmod +x .git/hooks/#{hook_name}"
      }
    end
  }
end

dep 'web repo exists', :path do
  requires 'git'
  path.ask("Where should the repo be created").default("~/current")
  met? { (path / '.git').dir? }
  meet {
    cd path, :create => true do
      shell "git init"
    end
  }
end

dep 'pushed.repo' do
  requires 'remote exists.repo'
  setup { repo.repo_shell "git fetch #{var(:remote_name)}" }
  met? {
    repo.repo_shell("git rev-parse --short #{var(:deploy_ref)}") ==
    repo.repo_shell("git rev-parse --short #{var(:remote_name)}/#{var(:deploy_ref)}")
  }
  meet { repo.repo_shell "git push #{var(:remote_name)} #{var(:deploy_ref)}", :log => true }
end

dep 'remote exists.repo' do
  def remote_url
    repo.repo_shell("git config remote.#{var(:remote_name)}.url")
  end
  met? { remote_url == var(:remote_url) }
  meet {
    if remote_url.blank?
      log "The #{var(:remote_name)} remote isn't configured."
      repo.repo_shell("git remote add #{var(:remote_name)} '#{var(:remote_url)}'")
    elsif remote_url != var(:remote_url)
      log "The #{var(:remote_name)} remote has a different URL (#{var(:remote_url)})."
      repo.repo_shell("git remote set-url #{var(:remote_name)} '#{var(:remote_url)}'")
    end
  }
end
