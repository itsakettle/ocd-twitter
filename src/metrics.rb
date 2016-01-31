require 'date'
require 'aws-sdk'
module OcdTweets

	class Metrics
    
    NAMESPACE = 'Ocd_Tweets'
    
    def self.client
      @client ||= Aws::CloudWatch::Client.new(region: "eu-west-1")
    end
  
    def self.put_tweet(tweet_timestamp)
      metric_name = 'tweet'
      unit = "Count"
      ts = DateTime.strptime(tweet_timestamp,"%a %b %d %H:%M:%S %z %Y")
      h = {namespace: NAMESPACE,
           metric_data: [{metric_name: metric_name, timestamp: ts, unit: unit, value: 1.0}]
          }
    
      client.put_metric_data(h)
    end
    
    def self.put_queue(time)
      metric_name = 'queue'
      unit = "Count"
      h = {namespace: NAMESPACE,
           metric_data: [{metric_name: metric_name, timestamp: time, unit: unit, value: 1.0}]
          }
    
      client.put_metric_data(h)
    end
    
    def self.put_worker_error(time)
      metric_name = 'worker_error'
      unit = "Count"
      h = {namespace: NAMESPACE,
           metric_data: [{metric_name: metric_name, timestamp: time, unit: unit, value: 1.0}]
          }
    
      client.put_metric_data(h)
    end
    
  end
end