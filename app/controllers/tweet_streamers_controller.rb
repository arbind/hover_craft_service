class TweetStreamersController < ApplicationProtectedController
  before_action :set_tweet_streamer, only: [:show, :destroy, :populate_from_streamer]
  before_action :set_tweet_streamers, only: [:index]

  def index
  end

  def show
  end

  def create
    session[:signup_streamer] = true
    redirect_to authorize_tweet_stream_url
  end

  def destroy
    hover_crafts_deps = HoverCraft.where(tweet_streamer_id: @tweet_streamer.id)
    delete_count = hover_crafts_deps.count
    hover_crafts_deps.delete_all
    @tweet_streamer.delete
    notice = "Deleted #{@tweet_streamer.screen_name} TweetStreamer and #{delete_count} hover crafts"
    redirect_to tweet_streamers_path notice: notice
  end

  def populate_from_streamers
    WorkLauncher.launch :populate_from_streamers
    redirect_to tweet_streamers_path, flash: {info: 'All TweetStreamers scheduled to populate HoverCrafts'}
  end

  def populate_from_streamer
    WorkLauncher.launch :populate_from_streamer, @tweet_streamer
    redirect_to tweet_streamers_path, flash: {info: "@#{@tweet_streamer.screen_name} scheduled to populate HoverCrafts"}
  end

  private

  def set_tweet_streamers
    @tweet_streamers = TweetStreamer.all
  end

  def set_tweet_streamer
    id = params[:id] || params[:tweet_streamer_id]
    @tweet_streamer = TweetStreamer.find(id)
  end

  def authorize_tweet_stream_url
    "/auth/twitter?force_login=true&screen_name=#{params[:screen_name]}"
  end
end
