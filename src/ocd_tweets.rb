require 'tweetstream'
require 'yaml'
require 'twitter'
require_relative 'tweet_job.rb'

module OcdTweets
  
  TRACK_STRING = 'ocd'
  
  def self.creds
    @creds ||= YAML.load_file('./config/creds.yml')
  end
  
  def self.client
    
    creds = credentials
    
    TweetStream.configure do |config|
      config.consumer_key       = creds['consumer_key']
      config.consumer_secret    = creds['consumer_secret']
      config.oauth_token        = creds['oauth_token']
      config.oauth_token_secret = creds['oauth_token_secret']
      config.auth_method        = :oauth
    end
    
    TweetStream::Client.new
    
  end
  
  def self.rest_client
    
    @rest_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = creds['consumer_key']
      config.consumer_secret     = creds['consumer_secret']
      config.access_token        = creds['oauth_token']
      config.access_token_secret = creds['oauth_token_secret']
    end
  
    
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
  
  def self.get_users(users:)
    rest_client.users(users)
  end


end
