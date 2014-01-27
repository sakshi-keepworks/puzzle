require 'twitter'
require 'json'
require 'sinatra'

client = Twitter::REST::Client.new do |config|
    config.consumer_key        = "------"
    config.consumer_secret     = "----------"
    config.access_token        = "--------------"
    config.access_token_secret = "------------------"
end

set :server, 'webrick'

get '/twitter/:name' do
    content_type :json
    # get first 2 tweets
    tweets = client.user_timeline(params[:name])[0..1]
    arr = []
    
    # for each tweet, get the retweeters
    tweets.each do |tweet|
        retweeters = client.retweeters_of(tweet.id)

        retweeters.each do |retweeter|
            ob = {}
            ob[:name] = retweeter.name
            ob[:followers_count] = retweeter.followers_count
            arr.push(ob)
        end

    end
    # remove the duplicates and sort on the users with the most followers
    sorted_influencers = arr.sort_by { |hsh| hsh[:followers_count] }
    sorted_influencers.reverse!
    sorted_influencers[0..9]
end
