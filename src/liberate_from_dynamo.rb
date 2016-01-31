require_relative 'tweet_db'
require_relative 'tweet_store'

module OcdTweets
  module LiberateFromDynamo
    
    def self.liberate(pages: nil)
      log_file = File.new('liberate_tweets.log','w')
      log_file.sync = true
      logger = Logger.new log_file
    
      tweets =  get_dynamo_tweets(logger: logger, pages: pages)
      tweets.map do |tw|

      OCDTweets::TweetDB.put_tweet(user_id: tw['user_id'], 
                         tweeted: tw['timestamp'], 
                         small_tweet: tw['small_tweet'])
      
      end
    end
    
    def self.get_dynamo_tweets(logger: , pages: nil)
    
      start_key = nil
      tweets = []
      select = ['user_id','#ts','small_tweet']
      p = 0
      loop do 
        t = OcdTweets::TweetStore.get_tweets(start_key: start_key,
                                            projection_expression: select.join(','))
        start_key = t.last_evaluated_key
        tweets.concat t.items
        p = p+1
        logger.info 'whiling ' 
        logger.info '  scanned ' + t.scanned_count.to_s + ' and got ' + t.count.to_s
        
        break if start_key == nil
        break if !pages.nil? && p >= pages # Order matters here!
      end
    
      tweets
    
    end  
    
  end
end