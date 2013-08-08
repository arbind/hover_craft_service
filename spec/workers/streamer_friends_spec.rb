# require 'spec_helper'
# require 'sidekiq/testing'

# describe :streamer_friends do
#   let (:subject)   { WorkerRefreshStreamers.new }
#   let!(:streamers) { create_list TweetStreamer, 3 }
#   it 'schedules each streamer to be refreshed' do
#     streamers.each do |streamer|
#       job_data = WorkerDetectNewStreamerFriends.work_data streamer
#       WorkerDetectNewStreamerFriends.should_receive(:schedule).with(job_data)
#     end
#     subject.perform
#   end
#   it 'queues a WorkerCreateHoverCraftsForNewStreamerFriends job' do
#     expect {
#       subject.perform
#     }.to change(WorkerDetectNewStreamerFriends.jobs, :size).by(streamers.size)
#   end
# end