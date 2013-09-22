class AuthorizedUsers
  include Mongoid::Document
  include Mongoid::Timestamps

  field :authorizations, type: Hash, default: {}

  private_class_method :new
  @@instance = nil

  def self.service
    return @@instance ||= AuthorizedUsers.first_or_create
  end

  def authorized?(twitter_id)
    authorizations.include? twitter_id
  end

  def authorize(twitter_id_name_hash)
    twitter_id_name_hash.each do |twitter_id, name|
      authorizations[twitter_id] = name
    end
    save
  end

  def unauthorize(twitter_id_name_hash)
    twitter_id_name_hash.each do |twitter_id, name|
      authorizations.delete twitter_id
    end
    save
  end
end