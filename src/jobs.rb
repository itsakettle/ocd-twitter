require_relative 'tweet_store.rb'
module Jobs
  class TweetJob

    @queue = :oneq

    
    def self.perform
      Hello::Extra.new.help
    end
    
  end 

end

