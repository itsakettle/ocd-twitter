module OCDTweets
  module BoilerroomDB
    require 'pg'
    require 'yaml'
  
    def self.conn 
      creds = YAML.load_file('config/database.yml')
      if @conn.nil? then
         @conn = PGconn.open(host: creds['host'], 
                           dbname: creds['boilerroom_database'],
                           user: creds['username'],
                           password: creds['password'])
          @conn.prepare('insert_tweet', 
                        'insert into observations (project_id, identifier, text_data, created_at, updated_at) values ($1, $2, $3, now(), now())')
      end
      @conn
    end
  
    def self.write_tweet(project_id:, identifier:, text_data:)
      conn.exec_prepared('insert_tweet', [project_id, identifier, text_data])
    end
    
  end
end