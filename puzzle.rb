require 'json'
require 'sinatra'
require 'date'
require 'thread'
require 'twitter'

set :server, 'webrick'

set :haml, :format => :html5

class MyCache
  def initialize()
    @mutex = Mutex.new
    @last_update = DateTime.new            # by default, -4732 BC
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ""
      config.consumer_secret     = ""
      config.access_token        = ""
      config.access_token_secret = ""
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
          ob[:name] = retweeter.name
          ob[:followers_count] = retweeter.followers_count
          arr.push(ob)
        end

        # remove the duplicates and sort on the users with the most followers,
        sorted_influencers = arr.sort_by { |hsh| hsh[:followers_count] }
        sorted_influencers.reverse!
        @cache = sorted_influencers[0..9].to_s
      end

      @cache
    end
  end
end

my_cache = MyCache.new

get '/' do
  content_type :json
  my_cache.get_cache
end