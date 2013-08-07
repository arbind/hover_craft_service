class Spyder
  include Singleton

  def self.service
    instance
  end

  def twitter_friends
    Twitter.friends(213747670)
  end
end