require 'spec_helper'
require 'sidekiq/testing'

describe :populate_from_streamers do
  let!(:streamers) { create_list TweetStreamer, 3 }
  it 'schedules to PopulateFromStreamer for each streamer' do
    streamers.each do |streamer|
      job_data = PopulateFromStreamer.work_data streamer
      PopulateFromStreamer.should_receive(:schedule).with(job_data)
    end
    TwitterHandler.populate_from_streamers
  end

  it 'queues PopulateFromStreamers jobs' do
    expect {
      TwitterHandler.populate_from_streamers
    }.to change(PopulateFromStreamer.jobs, :size).by(streamers.size)
  end
end