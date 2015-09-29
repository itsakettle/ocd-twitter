require 'date'
module OcdTweets

	class Metrics
  
    def self.client
      Aws::CloudWatch::Client.new(region: "eu-west-1")
    end
  
    def self.put(tweet_timestamp)
      namespace = 'Ocd_Tweets'
      metric_name = 'tweet'
      unit = "Count"
      ts = DateTime.strptime(tweet_timestamp,"%a %b %d %H:%M:%S %z %Y")
      h = {namespace: namespace,
           metric_data: [{metric_name: metric_name, timestamp: ts, unit: unit, value: 1.0}]
          }
    
      client.put_metric_data(h)
    end
  end
end