require "bundler/vlad"

set :shared_paths, {
  'system'  => 'public/system',
  'pids'    => 'tmp/pids',
  'sockets' => 'tmp/sockets',
  'bundle'  => '.bundle',
  'assets'  => 'public/assets'
}

set :application , "random-meme"
set :repository  , "/etc/code/random-meme"
set :revision    , "origin/vlad"
set :deploy_to   , "/var/www/randommeme"
set :perm_owner  , "randommeme"
set :perm_group  , "randommeme"

def rake(command)
  run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake #{command}"
end

def invoke(task)
  Rake::Task[task].invoke
end

task :staging do
  set :rails_env , "staging"
  set :domain    , "randommeme@192.168.51.50"
end

namespace :vlad do
  desc "Precompile assets"
  remote_task :assets_precompile, :roles => :app do
    rake "assets:precompile"
  end
 
  desc 'Restart Unicorn'
  remote_task :start_app, :roles => :app do
    run "/etc/init.d/randommeme restart"
  end

  desc "Deploy"
  task :deploy do
    puts "Updating code"
    invoke "vlad:update"
    puts "Installing gems"
    invoke "vlad:bundle:install"
    # puts "Migrating database"
    # invoke "vlad:migrate"
    puts "Precompiling assets"
    invoke "vlad:assets_precompile"
    puts "Restarting app"
    invoke "vlad:start_app"
    puts "Cleaning up"
    invoke "vlad:cleanup"
  end
end

