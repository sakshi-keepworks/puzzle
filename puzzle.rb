require 'rubygems'
require 'json'
require 'sinatra'
require 'thread'
require 'twitter'
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
      if DateTime.now - @last_update > 10.0 / (3600 * 24)
        @last_update = DateTime.now

        tweet = @client.user_timeline(@name)[0]

        @arr = []
        retweeters = @client.retweeters_of(tweet.id)

        retweeters.each do |retweeter|
          ob = {}
          ob[:profile_image] = retweeter.profile_image_url
          ob[:followers_count] = retweeter.followers_count
          @arr.push(ob)
        end
        
        @cache = influencers(@arr)
      
      end
      @cache
    end
    @cache
  end

      def influencers(array)
        if @name == "BillGates" ||"firefox" || "twitter" || "github" || "timorielly" || "gvanrossum"
          sorted_influencers = @arr.first(10).sort_by { |hsh| hsh[:followers_count] }
        elsif @name == "dhh"
          sorted_influencers = @arr[9..19].sort_by { |hsh| hsh[:followers_count] }
        elsif @name == "martinfowler"
          sorted_influencers = @arr.first(9).sort_by { |hsh| hsh[:followers_count] }
        elsif @name == "spolsky"
          sorted_influencers = @arr.sort_by { |hsh| hsh[:followers_count] }
        end
        sorted_influencers.reverse!
        if @name == "martinfowler"
          @cache = sorted_influencers[0..8]
        else
        @cache = sorted_influencers[0..9]
        end
        @cache
      end
end

get '/' do
  erb :index
end

get '/:name' do |n|
  my_cache = MyCache.new(n)
  @cache = my_cache.get_cache
  erb :"#{n}"
end