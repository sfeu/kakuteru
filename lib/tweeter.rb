
require 'mechanize'

class Tweeter
  
  def initialize(username)
    @username = username
  end
  
  def profile_image_url
    tweets = self.tweets
    tweets.blank? ? nil : tweets.first['user']['profile_image_url']
  end
  
  def tweets
    agent = WWW::Mechanize.new
    response = agent.get("http://twitter.com/statuses/user_timeline/#{@username}.json")
    if response.code.to_i != 200
      return nil
    end
    ActiveSupport::JSON.decode(response.body)
  rescue ActiveSupport::JSON::ParseError => pe
    return nil
  rescue => e
    return nil
  end
  
end