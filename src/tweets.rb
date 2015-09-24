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
      tw = status.attrs
      smaller_tweet = {'coordinates' => tw[:coordinates],
        'created_at' => tw[:created_at],
        'favorite_count' => tw[:favorite_count],
        'id_str' => tw[:id_str],
        'lang' => tw[:lang],
        'place' => tw[:place],
        'possibly_sensitive' => tw[:possibly_sensitive],
        'retweet_count' => tw[:retweet_count],
        'retweeted_status' => tw[:retweeted_status],
        'text' => tw[:text],
        'truncated' => tw[:truncated],
        'user_id' => tw[:user][:id],
        'time_zone' => tw[:user][:time_zone]}
      puts smaller_tweet.attrs.to_s.bytesize
    end
    
  end


end
