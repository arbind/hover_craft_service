class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :current_user
  # rescue_from Exception, :with => :bounce

  helper_method :current_user

  def styleguide
    redirect_to 'http://bootswatch.com/cyborg/'
  end

  def current_user
    @current_user ||= TwitterUser.where(twitter_id: session[:current_user]).first
  rescue
    ensure_logout
  end

  protected

  def ensure_login
    redirect_to login_path unless current_user
  end

  def ensure_logout
    session.delete :current_user
    session.delete :signup_streamer
    @current_user = nil
  end

  def bounce(exception)
    ensure_logout
    notice = exception.to_s
    p notice
    redirect_to login_path, notice: notice
  end
end
