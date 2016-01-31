module OCDTweets
  module TweetDB
    require 'pg'
    require 'yaml'
  
    def self.conn 
      creds = YAML.load_file('config/database.yml')
      if @conn.nil? then
         @conn = PGconn.open(host: creds['host'], 
                           dbname: creds['tweet_database'],
                           user: creds['username'],
                           password: creds['password'])
          @conn.prepare('insert_tweet', 'insert into ocd_tweets (tweet_id, user_id, tweeted, small_tweet, small_user) values ($1, $2, $3, $4, $5)')
      end
      @conn
    end
  
    def self.write_tweet(tweet_id:, user_id:, tweeted:, small_tweet:, small_user:)
      conn.exec_prepared('insert_tweet', [tweet_id, user_id, tweeted, small_tweet, small_user])
    end

  end
end