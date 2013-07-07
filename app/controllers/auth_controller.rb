class Denied < Exception
end

class AuthController < ApplicationController

  def new
    ensure_logout
  end

  def logout
    ensure_logout
    redirect_to login_path
  end

  def oauth_sign_in # actually sign in in here!
    signup_streamer = session.delete :signup_streamer
    if signup_streamer
      tweet_streamer = authorize_streamer
      notice = "#{tweet_streamer.screen_name} is authorized as a Tweet Streamer"
      redirect_to tweet_streamers_path, notice: notice
    else
      sign_in
      redirect_to dashboard_path
    end
  end

  def oauth_failure
    ensure_logout
    redirect_to login_path
  end

  protected

  def sign_in
    ensure_logout
    ensure_authorized_user
    params = user_hash
    tid = params[:twitter_id]
    u = TwitterUser.where(twitter_id: tid).first_or_create
    u.update_attributes(params)
    session[:current_user] = tid
  end

  def authorize_streamer
    ensure_tweet_streamer
    params = streamer_hash
    tid = params[:twitter_id]
    u = TweetStreamer.where(twitter_id: tid).first_or_create
    u.update_attributes(params)
    u
  end

  def ensure_tweet_streamer
  end

  def ensure_authorized_user
    unless AuthorizedUsers.service.authorized? oauth_hash.uid
      u = user_hash
      raise Denied.new "#{u[:name]}[#{u[:twitter_id]}] is not in Authorized list!"
    end
  end

  def user_hash
    {
      twitter_id:   "#{oauth_hash.uid}",
      token:        oauth_credentials.token,
      secret:       oauth_credentials.secret,
      name:         oauth_info.name,
      screen_name:  oauth_info.nickname,
      image:        oauth_info.image,
      twitter_account_created_at: oauth_raw_info.created_at,
    }
  end

  def streamer_hash
    {
      twitter_id:   "#{oauth_hash.uid}",
      token:        oauth_credentials.token,
      secret:       oauth_credentials.secret,
      name:         oauth_info.name,
      screen_name:  oauth_info.nickname,
      address:      oauth_raw_info.location,
      description:  oauth_raw_info.description,
      twitter_account_created_at: oauth_raw_info.created_at,
    }
  end

  def oauth_hash
    request.env['omniauth.auth']
  end

  def oauth_credentials
    oauth_hash.credentials || {}
  end

  def oauth_info
    oauth_hash.info || {}
  end

  def oauth_raw_info
    extra = oauth_hash.extra if oauth_hash
    raw_info = extra.raw_info if extra
    raw_info ||= {}
  end

end
