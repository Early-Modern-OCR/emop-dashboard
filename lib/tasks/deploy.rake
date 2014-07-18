# encoding: UTF-8

namespace :deploy do
	def run(desc, cmd)
		puts "============================"
		puts "============================"
		puts desc
		puts "============================"
		puts "============================"
		puts cmd
		puts `#{cmd}`
	end

	desc "Simple script to do deployment without capistrano"
	task :here => :environment do
		puts "Deploy from git to the current location"
		run("Get latest code", 'git pull')
		run("Update the ruby gems", 'bundle install')
		run("Update the database", 'rake db:migrate')
		run("Compile the assets", 'rake assets:precompile')
		run("Restart the website", 'touch tmp/restart.txt')
	end
end

