require "bundler/vlad"

set :application , "random-meme"
set :repository  , "/etc/code/random-meme"
set :deploy_to   , "/var/www/randommeme"
set :domain      , "randommeme@192.168.51.50"
set :web_command , "/etc/init.d/randommeme"

task "vlad:deploy" => %w[
  vlad:update vlad:bundle:install vlad:start_app vlad:cleanup
]
