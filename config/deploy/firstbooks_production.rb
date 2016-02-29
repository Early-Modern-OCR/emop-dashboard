require 'net/ssh/proxy/command'

# Read in the site-specific information so that the initializers can take advantage of it.
config_file = "config/secrets.yml"
if File.exists?(config_file)
   set :site_specific, YAML.load_file(config_file)['capistrano']['firstbooks_production']
   if fetch(:site_specific).nil?
     puts "*** Failed to load edge capistrano config"
   end
else
   puts "***"
   puts "*** Failed to load capistrano configuration. Did you create #{config_file} with a capistrano section?"
   puts "***"
end

set :application, 'firstbooks-dashboard'
set :stage, :firstbooks_production
set :rails_env, 'production'

server fetch(:site_specific)['ssh_name'], user: fetch(:site_specific)['user'], roles: %w{web app db}
set :deploy_to, "#{fetch(:site_specific)['deploy_base']}"
set :rvm1_ruby_version, fetch(:site_specific)['ruby']

set :ssh_options, {
  forward_agent: true,
  auth_methods: %w(publickey),
  keys: %w(~/.ssh/id_rsa),
  #verbose: :debug,
}
