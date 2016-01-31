module OCDTweets
  module TweetDB
    require 'pg'
    require 'yaml'
  
    def self.conn 
      creds = YAML.load_file('config/database.yml')
      if @conn.nil? then
         @conn = PGconn.open(host: creds['host'], 
                           dbname: creds['database'],
                           user: creds['username'],
                           password: creds['password'])
          @conn.prepare('insert_tweet', 'insert into ocd_tweets (user_id, tweeted, small_tweet) values ($1, $2, $3)')
      end
      @conn
    end
  
    def self.put_tweet(user_id:, tweeted:, small_tweet:)
      conn.exec_prepared('insert_tweet', [ user_id, tweeted, small_tweet ])
    end

  end
end