set :bundle_flags,  '--with mysql'
set :bundle_without, 'test production'
set :rails_env, 'development'
server '192.168.1.10', roles: %w{web app resque_worker resque_scheduler}, user: 'vagrant'
