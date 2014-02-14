Multunus puzzle
======

This is the solution of the Multunus puzzle. It fetches 2 recent tweets of a user and displays 10 retweeters in the descending order of their no. of followers in json.
The Sinatra gem has been used to build the web application. It uses Twitter gem to grab the twitter data.

Goto to https://dev.twitter.com/ and create your app. Your consumer key and secret will be generated. Create your access token and access secret(which should not be revealed). And copy and paste those details in puzzle.rb file. 

Do:

    $gem install sinatra
    $gem install json
    $gem install twitter

    $ruby app.rb

Go to the browser to view the output:

    localhost:4567/twitter/twitter_handle

That's all !

Deployed here: http://infinite-stream-4706.herokuapp.com/

