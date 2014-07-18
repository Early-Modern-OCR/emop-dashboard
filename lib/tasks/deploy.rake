# encoding: UTF-8

namespace :deploy do
	def run(cmd)
		puts cmd
		puts `cmd`
	end

	desc "Simple script to do deployment without capistrano"
	task :here => :environment do
		puts "Deploy from git to the current location"
		run('git pull')
		run('bundle install')
		run('rake db:migrate')
		run('rake assets:precompile')
		run('touch tmp/restart.txt')
	end
end

