#! /bin/bash

# try to kill the currently running app
(kill -9 $(cat /var/run/ocd_tweets.pid) && rm ocd_tweets.pid) || printf  "ocd_tweets isn't running\n"
# Make sure workers are killed
bundle exec rake kill_workers
# Start the one worker we want
bundle exec rake resque:work QUEUE='*' TERM_CHILD=1 INTERVAL=1 BACKGROUND=yes 
# Start looking for tweets
nohup bundle exec rake stream > ocd_tweets.log 2>&1&
echo $! > ocd_tweets.pid