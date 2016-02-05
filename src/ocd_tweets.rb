require 'tweetstream'
require 'yaml'
require 'twitter'
require 'json'
require_relative 'metrics.rb'
require_relative 'tweet_db.rb'
require_relative 'boilerroom_db.rb'

module OcdTweets
  
  TRACK_STRING = 'ocd'
  BOILERROOM_EVERY = 30
  @tweet_count = 0;
  
  def self.creds
    @creds ||= YAML.load_file('./config/creds.yml')
  end
  
  def self.logger
    @logger = Logger.new(STDOUT)
  end
  
  def self.client
    
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
      handle_tweet(tweet: tweet)
      @tweet_count = @tweet_count + 1

    end
    
  end
  
  def self.handle_tweet(tweet:)
    
    begin
      tweet_id = tweet[:id_str]
      user = tweet[:user]
      user_id = user[:id_str]
      timestamp = DateTime.strptime((tweet[:timestamp_ms].to_f/1000).to_s, '%s').iso8601
      small_tweet = {'coordinates' => tweet[:coordinates],
        'favorite_count' => tweet[:favorite_count],
        'id_str' => tweet[:id_str],
        'lang' => tweet[:lang],
        'place' => tweet[:place],
        'source' => tweet[:source],
        'possibly_sensitive' => tweet[:possibly_sensitive],
        'retweet_count' => tweet[:retweet_count],
        'text' => tweet[:text],
        'truncated' => tweet[:truncated],
        'time_zone' => user[:time_zone]}
      
        small_user = {'description' => user[:description],
        'favorite_count' => user[:favourites_count],
        'followers_count' => user[:followers_count],
        'friends_count' => user[:friends_count],
        'lang' => user[:lang],
        'location' => user[:location],
        'name' => user[:name],
        'statuses_count' => user[:statuses_count]}
        
        OCDTweets::TweetDB.write_tweet(tweet_id: tweet_id,
                          user_id: user_id,
                          tweeted: timestamp, 
                          small_tweet: small_tweet.to_json, 
                          small_user: small_user.to_json)
    
      # Write to boileroom every few tweets
      if @tweet_count % BOILERROOM_EVERY == 0 then
        OCDTweets::BoilerroomDB.write_tweet(project_id: 1, 
                                 identifier: small_tweet['id_str'], 
                                 text_data: small_tweet['text'])
      end
    
      Metrics.put_tweet(tweet[:created_at])
    rescue Exception => e
      logger.info e
      Metrics.put_worker_error(Time.now)
    end
  
  end


end
