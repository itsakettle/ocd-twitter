require 'rake'
require 'rspec/core/rake_task'
require './src/ocd_tweets.rb'
require 'resque/tasks'
require './src/tweet_job.rb'
require 'resque'
require './src/user_details_retro.rb'
 
RSpec::Core::RakeTask.new(:spec) do |t|
t.pattern = Dir.glob('spec/**/*_spec.rb')
t.rspec_opts = '--format documentation'
# t.rspec_opts << ' more options'
t.rcov = true
end
task :default => :spec

desc 'stream ocd tweets'
task :stream do 
  
  OcdTweets.ocd_tweets
  
end

desc 'resque test'
task :resque_test do
  Resque.enqueue(Jobs::TweetJob )
  
  #Jobs::TweetJob.new(user_id: 12, 
  #timestamp: Time.now.strftime("%d/%m/%Y %H:%M"),
  #status: 'hi').perform
  
end


desc 'kill resque workers'
task :kill_workers do
  pids = Array.new

  puts "Killing resque workers ... "
  Resque.workers.each do |worker|
    pids << worker.to_s.split(/:/)[1]
  end
  puts pids
  if pids.size > 0
     system("kill -QUIT #{pids.join(' ')}")
  end
end

desc 'get a twitter users'
task :get_twitter_users, [:users] do |t, args|
  
  u = args[:users].split(" ")
  u = u.map { |a| a.to_i}
  puts OcdTweets.get_users(users: u).map {|u| u.to_h}
end

desc 'test getting users'
task :test_retro do
 
 UserDetailsRetro.get_users_retro 
 
end

