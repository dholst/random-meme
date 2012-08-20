require "bundler/capistrano"

set :application                , "random-meme"
set :scm                        , :git
set :repository                 , "https://github.com/dholst/random-meme.git"
set :branch                     , "origin/master"
set :deploy_to                  , "/var/www/randommeme"
set :normalize_asset_timestamps , false
set :user                       , "randommeme"
set :use_sudo                   , false

task :staging do
  set :rails_env, "staging"
  server "192.168.51.50", :app, :web
end

set(:latest_release)    {fetch(:current_path)}
set(:release_path)      {fetch(:current_path)}
set(:current_release)   {fetch(:current_path)}
set(:current_revision)  {capture("cd #{current_path}; git rev-parse --short HEAD").strip}
set(:latest_revision)   {capture("cd #{current_path}; git rev-parse --short HEAD").strip}
set(:previous_revision) {capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip}

desc "tail log files"
task :tail, :roles => :app do
  run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile:primary"
    end
  end

  desc "deploy the latest"
  task :default do
    update
    restart
  end

  task :cold do
    update
    migrate
  end

  task :update do
    transaction do
      update_code
    end
  end

  task :update_code, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }

    cmd = []
    cmd << "if [ ! -d #{current_path} ]; then"
    cmd << " git clone #{repository} #{current_path};"
    cmd << " mkdir -p #{dirs.join(" ")};"
    cmd << " chmod g+w #{dirs.join(" ")};"
    cmd << "fi;"

    cmd << "cd #{current_path};"
    cmd << "git fetch origin;"
    cmd << "git reset --hard #{branch};"

    run cmd.join(" ")
    finalize_update
  end

  task :migrations do
    transaction do
      update_code
    end
    migrate
    restart
  end

  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    run <<-CMD
      rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc "restart unicorn"
  task :restart, :except => { :no_release => true } do
    run "/etc/init.d/unicorn restart /etc/unicorn/randommeme.conf"
  end

  desc "start unicorn"
  task :start, :except => { :no_release => true } do
    run "/etc/init.d/unicorn start /etc/unicorn/randommeme.conf"
  end

  desc "stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "/etc/init.d/unicorn stop /etc/unicorn/randommeme.conf"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end
