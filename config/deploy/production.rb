set :bundle_flags,  '--with mysql'
set :bundle_without, 'development test'
set :deploy_to, '/var/www/avalon'
set :rails_env, 'production'
server 'yul-av-prd1.library.yale.internal', roles: %w{web app resque_worker resque_scheduler}, user: 'avalon'
set :ssh_options, {
  keys: %w{~/.ssh/id_rsa},
  forward_agent: false,
  auth_methods: %w{publickey}
}
