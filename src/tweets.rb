require 'tweetstream'
require 'yaml'

module Tweets

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
    
    client.track('ocd') do |status|
      puts "#{status.text}"
    end
    
  end


end
