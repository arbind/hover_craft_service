require 'spec_helper'
require 'sidekiq/testing'

describe WorkerRefreshStreamers do
  let (:subject)   { WorkerRefreshStreamers.new }
  let!(:streamers) { create_list TweetStreamer, 3 }
  it 'schedules each streamer to be refreshed' do
    streamers.each do |s|
      job_data = WorkerDetectNewStreamerFriends.work_data s.id
      WorkerDetectNewStreamerFriends.should_receive(:schedule).with(job_data)
    end
    subject.perform
  end
  it 'queues a WorkerCreateHoverCraftsForNewStreamerFriends job' do
    expect {
      subject.perform
    }.to change(WorkerDetectNewStreamerFriends.jobs, :size).by(streamers.size)
  end
end