require 'tweetstream'
require 'yaml'
require_relative 'tweet_job.rb'

module OcdTweets
  
  TRACK_STRING = 'ocd'
  
  def self.client
    
    # Need to get creds   
    creds = YAML.load_file('./config/creds.yml')
    
    TweetStream.configure do |config|
      config.consumer_key       = creds['consumer_key']
      config.consumer_secret    = creds['consumer_secret']
      config.oauth_token        = creds['oauth_token']
      config.oauth_token_secret = creds['oauth_token_secret']
      config.auth_method        = :oauth
    end
    
    TweetStream::Client.new
    
  end

  def self.ocd_tweets
    
    client.track(TRACK_STRING) do |tweet|
      tweet = tweet.attrs
      begin
        Resque.enqueue(TweetJob,tweet)
        Metrics.put_queue(Time.now)
        #TweetJob.perform(tweet: tweet)
      rescue Exception => e
        puts e
        raise e
      end
    end
    
  end


end
