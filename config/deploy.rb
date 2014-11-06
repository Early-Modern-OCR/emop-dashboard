lock '3.2.1'

set :repo_url, "git@github.tamu.edu:emop/emop-dashboard.git"
set :scm, :git
set :branch, :master

set :format, :pretty
set :log_level, :debug

set :linked_files, %w{
config/database.yml
config/secrets.yml
}

set :linked_dirs, %w{
log
tmp/cache
tmp/pids
tmp/sessions
tmp/sockets
vendor/bundle
}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc "Upload config files"
  task :upload_configs do
    on roles(:app) do |server|
      fetch(:linked_files).each do |f|
        upload! File.join("config/deploy", fetch(:stage).to_s, f), File.join(shared_path, f)
      end
    end
  end
end

#after 'deploy:setup', :setup_config
