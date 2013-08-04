require 'spec_helper'
require 'sidekiq/testing'

describe WorkerRefreshStreamers do
  let (:subject)   { WorkerRefreshStreamers.new }
  let!(:streamers) { create_list TweetStreamer, 3 }
  it 'schedules each streamer to be refreshed' do
    WorkerDetectNewStreamerFriends.should_receive(:schedule).exactly(streamers.size).times
    subject.perform
  end
  it 'queues a WorkerCreateHoverCraftsForNewStreamerFriends job' do
    expect {
      subject.perform
    }.to change(WorkerDetectNewStreamerFriends.jobs, :size).by(streamers.size)
  end
end