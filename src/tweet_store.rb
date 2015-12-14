require 'aws-sdk'

module OcdTweets
  
  class TweetStore
  
    def self.client 
      @client ||= Aws::DynamoDB::Client.new(region: "eu-west-1")
    end
    
    def self.table
      @table ||= YAML.load_file('./config/dynamo.yml')['dynamo_table']
    end
  
    def self.write_tweet(user_id:, timestamp:, small_tweet:)
      item = {user_id: user_id, timestamp: timestamp, small_tweet: small_tweet}
      client.put_item(table_name: table, item: item)
    end
    
    def self.get_tweets(start_key: ,projection_expression:, limit:)

      client.scan(projection_expression: projection_expression,
                  table_name: table,
                  exclusive_start_key: start_key,
                  expression_attribute_names: {"#ts" => "timestamp"},
                  limit: limit)

    end
    
    def self.update(user_id:, timestamp:, attribute:)
      key = {user_id: user_id, timestamp: timestamp}
      client.update_item(table_name: table, key: key, attribute_updates: attribute )
    end
  
  end
  
end
