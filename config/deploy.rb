require "bundler/capistrano"

set :application                , "random-meme"
set :scm                        , :git
set :repository                 , "https://github.com/dholst/random-meme.git"
set :branch                     , "capistrano"
set :deploy_to                  , "/var/www/randommeme"
set :user                       , "randommeme"
set :use_sudo                   , false
set :deploy_via                 , :remote_cache

task :staging do
  set :rails_env, "staging"
  server "192.168.51.50", :app, :web, :db, :primary => true
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "/etc/init.d/randommeme restart"
  end

  task :after_update_code do
    run "mkdir -p #{deploy_to}/#{shared_dir}/sockets"
    run "rm -rf #{current_release}/tmp/sockets"
    run "ln -s #{deploy_to}/#{shared_dir}/sockets #{current_release}/tmp/"
  end
end

