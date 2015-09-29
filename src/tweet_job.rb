require_relative 'tweet_store.rb'
require_relative 'metrics.rb'
require 'json'

module OcdTweets
  class TweetJob

    @queue = :ocd_tweets

    
    def self.perform(tweet)
      
      begin
        user_id = tweet["user"]["id_str"]
        #timestamp = DateTime.strptime(tweet[:created],"%a %b %d %I:%M:%S %z %Y").iso8601
        timestamp = DateTime.strptime((tweet["timestamp_ms"].to_f/1000).to_s, '%s').iso8601

        small_tweet = {'coordinates' => tweet["coordinates"],
          'favorite_count' => tweet["favorite_count"],
          'id_str' => tweet["id_str"],
          'lang' => tweet["lang"],
          'place' => tweet["place"],
          'source' => tweet["source"],
          'possibly_sensitive' => tweet["possibly_sensitive"],
          'retweet_count' => tweet["retweet_count"],
          'text' => tweet["text"],
          'truncated' => tweet["truncated"],
          'time_zone' => tweet["user"]["time_zone"]}
        
        TweetStore.write_tweet(user_id: user_id,timestamp: timestamp, small_tweet: small_tweet.to_json)
        Metrics.put(tweet['created_at'])
      rescue Exception => e
        puts e
        raise e
      end
      
    end
    
  end 

end

