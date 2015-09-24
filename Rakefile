require 'rake'
require 'rspec/core/rake_task'
require './src/tweets.rb'
require 'resque/tasks'
require './src/jobs.rb'
require 'resque'
 
RSpec::Core::RakeTask.new(:spec) do |t|
t.pattern = Dir.glob('spec/**/*_spec.rb')
t.rspec_opts = '--format documentation'
# t.rspec_opts << ' more options'
t.rcov = true
end
task :default => :spec

desc 'stream ocd tweets'
task :stream do 
  
  Tweets.ocd_tweets
  
end

desc 'resque test'
task :resque_test do
  Resque.enqueue(Jobs::TweetJob )
  
  #Jobs::TweetJob.new(user_id: 12, 
  #timestamp: Time.now.strftime("%d/%m/%Y %H:%M"),
  #status: 'hi').perform
  
end

