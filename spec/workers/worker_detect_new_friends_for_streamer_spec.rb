require 'spec_helper'
require 'sidekiq/testing'

describe WorkerDetectNewStreamerFriends do

  shared_examples_for 'a worker to DetectNewStreamerFriends' do
    it 'schedules all friends to be turned into hovercrafts' do
      WorkerCreateHoverCraftsForNewStreamerFriends.should_receive(:schedule).with streamer.id, new_friend_ids
      subject.perform streamer.id
    end
    it 'queues a WorkerCreateHoverCraftsForNewStreamerFriends job' do
      expect {
        subject.perform streamer.id
      }.to change(WorkerCreateHoverCraftsForNewStreamerFriends.jobs, :size).by(1)
    end
  end

  let (:subject)          { WorkerDetectNewStreamerFriends.new }

  let (:cursor)           { double Twitter::Cursor, ids: friend_ids, next: next_page}
  let (:friend_tids)      { (1000..1010).to_a }
  let (:next_page)        { 0 }

  let!(:streamer)         { create TweetStreamer }
  let (:friend_ids)       { friend_tids.map &:to_s }
  let (:new_friend_ids)   { new_friend_tids.map &:to_s }

  let (:new_friend_tids)  { friend_tids }

  before do
    Twitter.stub(:friend_ids).and_return cursor
  end

  context 'Process Streamer friends for the 1st time' do
    it_behaves_like 'a worker to DetectNewStreamerFriends'
  end

  context 'Process Streamer friends that were added' do
    let (:existing_friend_tids) { [ friend_tids[0], friend_tids[2], friend_tids[-2] ] }
    let (:new_friend_tids)      { friend_tids - existing_friend_tids }
    before do
      existing_friend_tids.each do |tid|
        create :twitter_hover_craft, tweet_streamer_id: streamer.id, twitter_id:"#{tid}"
      end
    end

    it_behaves_like 'a worker to DetectNewStreamerFriends'
    it 'schedules only the new friends to be turned into hovercrafts' do
      WorkerCreateHoverCraftsForNewStreamerFriends.should_receive(:schedule).with streamer.id, new_friend_ids
      subject.perform streamer.id
    end
  end

  context 'Given multiple pages of friends' do
    let (:next_page)        { 1 }
    it_behaves_like 'a worker to DetectNewStreamerFriends'
    it 'reschedules the job for the next page' do
      WorkerDetectNewStreamerFriends.should_receive(:schedule).with streamer.id, next_page
      subject.perform streamer.id
    end
  end
end