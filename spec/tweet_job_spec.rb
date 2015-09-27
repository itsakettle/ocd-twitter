require_relative '../src/tweet_job.rb'


describe TweetJob do 
  
  describe ".perform" do

    context "basic tweet" do
      
      before do
        @tweethash = {:created_at=>"Sun Sep 27 12:52:01 +0000 2015", 
          :id=>1234, 
          :id_str=>"1234", 
          :text=>"test test test", 
          :source=>"<a href=\"http://twitter.com/download/android\" rel=\"nofollow\">Twitter for Android</a>", 
          :truncated=>false, :in_reply_to_status_id=>nil, :in_reply_to_status_id_str=>nil, :in_reply_to_user_id=>nil, 
          :in_reply_to_user_id_str=>nil, :in_reply_to_screen_name=>nil, :user=>{:id=>4321, 
            :id_str=>"4321"}, 
          :geo=>nil, :coordinates=>nil, :place=>nil, :contributors=>nil, :is_quote_status=>false, :retweet_count=>0, :favorite_count=>0,
          :entities=>{:hashtags=>[], :urls=>[], :user_mentions=>[], :symbols=>[]}, :favorited=>false, :retweeted=>false, 
          :filter_level=>"low", :lang=>"en", :timestamp_ms=>"1443358321657"}
      end
      
      it "should " do
        TweetJob.perform(@tweethash).should 
      end
    end
  end

end