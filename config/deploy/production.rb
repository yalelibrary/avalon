# server-based syntax
set :bundle_flags,  '--with mysql'
set :bundle_without, 'test development'
set :rails_env, 'production'
#set :deploy_to, '$HOME/avalon'
server 'yul-av-prd1.library.yale.internal', roles: %w{web app resque_worker resque_scheduler}, user: 'avalon'
