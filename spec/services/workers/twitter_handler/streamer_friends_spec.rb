require 'spec_helper'
require 'sidekiq/testing'

describe :streamer_friends do
  let!(:streamers) { create_list TweetStreamer, 3 }
  it 'schedules StreamerFriendsNew for each streamer' do
    streamers.each do |streamer|
      job_data = StreamerFriendsNew.work_data streamer
      StreamerFriendsNew.should_receive(:schedule).with(job_data)
    end
    TwitterHandler.streamer_friends
  end

  it 'queues StreamerFriendsNew jobs' do
    expect {
      TwitterHandler.streamer_friends
    }.to change(StreamerFriendsNew.jobs, :size).by(streamers.size)
  end
end