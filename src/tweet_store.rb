require 'aws-sdk'

module OcdTweets
  
  class TweetStore
  
    TABLE = 'ocd_tweets'
  
    def self.client 
      @client ||= Aws::DynamoDB::Client.new(region: "eu-west-1")
    end
  
    def self.write_tweet(user_id:, timestamp:, small_tweet:)
      item = {user_id: user_id, timestamp: timestamp, small_tweet: small_tweet}
      client.put_item(table_name: TABLE, item: item)
    end
    
    def self.get_tweets(start_key: ,projection_expression:)

      client.scan(projection_expression: projection_expression,
                  table_name: TABLE,
                  exclusive_start_key: start_key,
                  expression_attribute_names: {"#ts":"timestamp"})

    end
    
    def self.update(user_id:, timestamp:, attribute:)
      key = {user_id: user_id, timestamp: timestamp}
      client.put_item(table_name: TABLE, key: key, attribute_updates: attribute )
    end
  
  end
  
end
