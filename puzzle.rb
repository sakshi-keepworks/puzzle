require 'rubygems'
require 'json'
require 'sinatra'
require 'thread'
require 'twitter'
require 'thin'

set :server, 'unicorn'

class MyCache
  def initialize()
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
      if DateTime.now - @last_update > 10.0 / (3600 * 24)
        @last_update = DateTime.now

        arr = []
        retweeters = @client.retweeters_of(429627812459593728)

        retweeters.each do |retweeter|
          ob = {}
          ob[:profile_image] = retweeter.profile_image_url
          ob[:followers_count] = retweeter.followers_count
          arr.push(ob)
        end

        # remove the duplicates and sort on the users with the most followers,
        sorted_influencers = arr.sort_by { |hsh| hsh[:followers_count] }
        sorted_influencers.reverse!
        @cache = sorted_influencers[0..9]
      end

      @cache
    end
    @cache
  end
end

my_cache = MyCache.new

get '/' do
  @cache = my_cache.get_cache
  erb :index
end