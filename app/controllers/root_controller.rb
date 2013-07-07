class RootController < ApplicationController
  def ping
    render json: :pong
  end
end