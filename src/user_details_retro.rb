require_relative 'ocd_tweets'
require_relative 'tweet_store'
require 'json'

module UserDetailsRetro
  
	def self.get_users_retro
    
    # First get the keys for each tweet, gonna need some pagination
    
    start_key = nil
    tweets = []
    loop do 
      select = ['user_id','#ts']
      t = OcdTweets::TweetStore.get_tweets(start_key: start_key, projection_expression: select)
      start_key = t.last_evaluated_key
      tweets << t
      puts 'whiling ' 
      puts '  scanned ' + t.scanned_count.to_s + 'and got ' + t.count.to_s
      break if start_key != nil
    end
  
    # So we have all the tweets, now we need to get user for each
    # Obv there will be some duplicate users here, but the cost is reasonable
    # Now for each tweet get the user and update dynamo. Do this in batches of 100
    
    # The twitter API allows us to make 180 calls in 15 minutes with each call giving 100 users. So let's go half this speed. So that's 90 calls per 15. So that's one call every 10 seconds. So to keep this really simple let's assume that the calls themselves and the updates to dynamo will take 3 seconds - on average. So let's sleep for 7 seconds after every call.
    
    # So this is tricky because it's possible that we might not get some users back. So we need to go through all the tweets and see if we got a user.
    
    to = 1
    from = 100
        
    loop do 
      
      # This is one call
      user_object = OcdTweets.get_users(this_call_tweets)
  
      this_call_tweets.maps do |tw| 
    
        tw_user = user_objects.select {|u| u.id == tw['user_id']} 
        
        if (!tw_user.nil?)  
          
          small_user = {tw_user.description,
          tw_user.favourites_count,
          tw_user.followers_count,
          tw_user.friends_count,
          tw_user.lang,
          tw_user.location,
          tw_user.name,
          tw_user.statuses_count,
          tw_user.time_zone}
       
          TweetStore.update(user_id: tw['user_id'], 
                            timestamp: tw['timestamp'], 
                            attribute: {'small_user' => {value: small_user.to_json}})
        end
        
        break if to == tweets.length
        
        sleep(7)
        
        from = from + 100
        to = max(to+100,tweets.length)
        this_call_tweets = tweets[from..to]
        
      end
        
    end


    
end