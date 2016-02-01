now=$(date +"%Y%m%d")
nohup bundle exec rake stream > ocd_tweets_$now.log 2>&1&
echo $! > ocd_tweets.pid