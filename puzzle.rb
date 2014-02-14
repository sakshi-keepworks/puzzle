require 'rubygems'
require 'json'
require 'sinatra'
require 'date'
require 'thread'
require 'twitter'
require 'thin'

set :server, 'unicorn'

set :html, :format => :html5
set :public_folder, 'public'

get '/' do
    #content_type :json
   @mutex = Mutex.new
    @last_update = DateTime.new            # by default, -4732 BC
  
   @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "QWIMPlplKgnAPDaw7t8zg"
      config.consumer_secret     = "7zLkAu0ThOMPFl5wyIv0U2QPID9WK0UfzFRQlrZQfUY"
      config.access_token        = "279382251-xUW4qVgceUD3BM61jk8FDgWJYPJp9QhTB9elGAVn"
      config.access_token_secret = "lvzYltp9uneL8VqNOZikayPUVvxvQgqna12z0q56o"
    end

     @mutex.synchronize do
      if DateTime.now - @last_update > 10.0 / (3600 * 24)
        @last_update = DateTime.now

        arr = []
        retweeters = @client.retweeters_of(429627812459593728)

        retweeters.each do |retweeter|
          ob = {}
          ob[:name] = retweeter.name
          ob[:profile_image] = retweeter.profile_image_url
          ob[:followers_count] = retweeter.followers_count
          arr.push(ob)
        end
        sorted_influencers = arr.sort_by { |hsh| hsh[:followers_count] }
        sorted_influencers.reverse!
        @cache = sorted_influencers[0..9]
        
        erb :index
      end
     end
end
