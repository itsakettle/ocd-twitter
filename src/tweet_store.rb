require 'aws-sdk'

module OcdTweets
  
  class TweetStore
  
    TABLE = 'ocd_tweets'
  
    def self.client 
      Aws::DynamoDB::Client.new(region: "eu-west-1")
    end
  
    def self.write_tweet(user_id:, timestamp:, small_tweet:)
      item = {user_id: user_id, timestamp: timestamp, small_tweet: small_tweet}
      client.put_item(table_name: TABLE, item: item)
    end
  
  end
  
end
