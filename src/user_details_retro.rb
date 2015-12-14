require_relative 'ocd_tweets'
require_relative 'tweet_store'
require 'json'
require 'benchmark'

module OcdTweets
  
  class UserDetailsRetro
  
  	def self.get_users_retro
    
      # First get the keys for each tweet, gonna need some pagination
      log_file = File.new('get_twitter_users.log','w')
      log_file.sync = true
      logger = Logger.new log_file
    
      tweets =  get_dynamo_tweets(logger: logger)
    
      logger.info  'finished paginating through Dynamo. Got ' +  tweets.length
  
      # So we have all the tweets, now we need to get user for each
      # Obv there will be some duplicate users here, but the cost is reasonable
      # Now for each tweet get the user and update dynamo. Do this in batches of 100
    
      # The twitter API allows us to make 180 calls in 15 minutes with each call giving 100 users. So let's go half this speed. So that's 90 calls per 15. So that's one call every 10 seconds. So to keep this really simple let's assume that the calls themselves and the updates to dynamo will take 3 seconds - on average. So let's sleep for 7 seconds after every call.
    
      # So this is tricky because it's possible that we might not get some users back. So we need to go through all the tweets and see if we got a user.
    
      slice_size = 100
      user_calls = tweets[0].each_slice(slice_size).to_a

      i = 0
    
      user_calls.each do |this_call_tweets| 
      
        time_to_write_dynamo = Benchmark.measure {
          do_one_call(this_call_tweets: this_call_tweets, logger: logger)
        }
        logger.info time_to_write_dynamo.to_s + '...writing call to dynamo'
        
        sleep(7)
       i = i+1
       if (i % 100 == 0)
         logger.info  'Ive done ' + i.to_s + ' calls' 
       end
        
      end

    end
  
    def self.get_dynamo_tweets(logger:)
    
      start_key = nil
      tweets = []
      select = ['user_id','#ts']
      loop do 
        t = OcdTweets::TweetStore.get_tweets(start_key: start_key
                                            , projection_expression: select.join(',')
                                            ,limit: 400)
        start_key = t.last_evaluated_key
        tweets << t.items
        logger.info 'whiling ' 
        logger.info '  scanned ' + t.scanned_count.to_s + ' and got ' + t.count.to_s
        break if start_key == nil
      end
    
      tweets
    
    end  
  
    def self.put_small_user_dynamo(tw:, tw_user:, logger:)
    
      if (!tw_user.nil?)  
     
        begin
          small_user = {'description' => tw_user.description.to_s,
          'favorite_count' => tw_user.favourites_count.to_s,
          'followers_count' => tw_user.followers_count.to_s,
          'friends_count' => tw_user.friends_count.to_s,
          'lang' => tw_user.lang.to_s,
          'location' => tw_user.location.to_s,
          'name' => tw_user.name.to_s,
          'statuses_count' => tw_user.statuses_count.to_s}

            OcdTweets::TweetStore.update(user_id: tw['user_id'], 
                              timestamp: tw['timestamp'], 
                              attribute: {'small_user' => {value: small_user.to_json, action:'PUT'}})

        rescue => e
            logger.error  'Error writing to dynamo ' + e.message + small_user.to_s
        end                  
                          
      end
    
    end
    
  
    def self.do_one_call(this_call_tweets:, logger: )

      logger.info 'Starting to get users...' 
      # This is one call
    
      user_ids_to_get = this_call_tweets.map {|x| x['user_id'].to_i}
    
      user_objects = nil
      time_to_get_tweets = Benchmark.measure {
        user_objects = OcdTweets.get_users(users: user_ids_to_get)
      }
    
      logger.info time_to_get_tweets.to_s + '...getting twitters users' 
    
      this_call_tweets.map do |tw| 

        begin
        
          tw_user = user_objects.select {|u| u.id == tw['user_id'].to_i}[0]
      
        rescue => e
          logger.error 'Error getting users ' + e.message 
        end
      
          put_small_user_dynamo(tw: tw, tw_user: tw_user, logger: logger)
    
      end
    
    end

  end
  
end