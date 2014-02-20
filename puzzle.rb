require 'rubygems'
require 'sinatra'
require 'twitter'
require 'thread'
require 'thin'

set :server, 'unicorn'

class MyCache

  attr_reader :name
  def initialize(name)
    @name = name
    @mutex = Mutex.new
    @last_update = DateTime.new            # by default, -4732 BC
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "QWIMPlplKgnAPDaw7t8zg"
      config.consumer_secret     = "7zLkAu0ThOMPFl5wyIv0U2QPID9WK0UfzFRQlrZQfUY"
      config.access_token        = "279382251-xUW4qVgceUD3BM61jk8FDgWJYPJp9QhTB9elGAVn"
      config.access_token_secret = "lvzYltp9uneL8VqNOZikayPUVvxvQgqna12z0q56o"
    end
  end

  def get_cache
    @mutex.synchronize do
      if DateTime.now - @last_update > 13.0 / (3600 * 24)
        @last_update = DateTime.now

        #Fetch the recent tweets of a twitter handle
        tweets = @client.user_timeline(@name)
        
        # fix, (fetch the tweets with more than 10 retweeters) 
        t = ""

        tweets.each do |tweet|
          if tweet.retweet_count > 10
            t = tweet # the tweet with retweeters
            break
          end
        end

        @arr = [] # list of retweeters
        retweeters = @client.retweeters_of(t.id)

        retweeters.each do |retweeter|
          ob = {}
          ob[:profile_image] = retweeter.profile_image_url_https
          ob[:followers_count] = retweeter.followers_count
          @arr.push(ob)
        end
        
        @arr = @arr.first(10)
        @arr.sort_by! { |k| k[:followers_count] }
        result = {}
        result[:user] = t.user
        result[:retweeters] = @arr.reverse
        @cache = result
      end
      @cache
      end
  end
    @cache
end 

get '/' do
  erb :index
end

get '/:name' do |n|
  my_cache = MyCache.new(n)
  @cache = my_cache.get_cache
  erb :"profile"
end
