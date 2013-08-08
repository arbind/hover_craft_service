require 'spec_helper'
require 'sidekiq/testing'

describe :streamer_friends_new do

  shared_examples_for 'a worker to detect new streamer friends' do
    it 'calls the Twitter.friends API' do
      Twitter.should_receive(:friend_ids).with(streamer.tid, {cursor: next_cursor_page})
      TwitterHandler.streamer_friends_new streamer, next_cursor_page
    end

    describe 'batch the friend ids' do # to match the limit(100) when calling Twitter.users
      let (:batches_of_ids) { new_friend_ids.each_slice(TWITTER_FETCH_USERS_BATCH_SIZE).to_a }
      it 'schedules StreamerFriendsCreate in batches of friend ids' do
        batches_of_ids.each do |ids|
          new_job_data = StreamerFriendsCreate.work_data streamer, ids
          StreamerFriendsCreate.should_receive(:schedule).with new_job_data
        end
        TwitterHandler.streamer_friends_new streamer, next_cursor_page
      end
      it 'schedules StreamerFriendsCreate for each batch' do
        expect {
          TwitterHandler.streamer_friends_new streamer, next_cursor_page
        }.to change(StreamerFriendsCreate.jobs, :size).by(batches_of_ids.size)
      end
    end
  end

  let (:streamer)         { create :streamer }
  let (:cursor)           { double Twitter::Cursor, ids: friend_ids, next: next_cursor_page}
  let (:friend_tids)      { (1000..1010).to_a }
  let (:next_cursor_page) { 0 }

  let!(:streamer)         { create :tweet_streamer }
  let (:friend_ids)       { friend_tids.map &:to_s }
  let (:new_friend_ids)   { new_friend_tids.map &:to_s }

  let (:new_friend_tids)  { friend_tids }

  before do
    Twitter.stub(:friend_ids).and_return cursor
  end

  context 'Process friends for the 1st time' do
    it_behaves_like 'a worker to detect new streamer friends'
  end

  context 'Process a page with a large number of friends in batches' do
    let (:friend_tids)      { (1000..1310).to_a }
    it_behaves_like 'a worker to detect new streamer friends'
  end

  context 'Processes multiple pages of friends' do
    let (:next_cursor_page)        { 1 }
    it_behaves_like 'a worker to detect new streamer friends'
    it 'schedules another job to process the next page' do
      next_job_data = StreamerFriendsNew.work_data streamer, next_cursor_page
      StreamerFriendsNew.should_receive(:schedule).with next_job_data
      TwitterHandler.streamer_friends_new streamer, next_cursor_page
    end
  end

  context 'Process only the new friends' do
    let (:existing_friend_tids) { [ friend_tids[0], friend_tids[2], friend_tids[-2] ] }
    let (:new_friend_tids)      { friend_tids - existing_friend_tids }
    before do
      existing_friend_tids.each do |tid|
        create :twitter_hover_craft, tweet_streamer: streamer, twitter_id:"#{tid}"
      end
    end

    it_behaves_like 'a worker to detect new streamer friends'
    it 'schedules only the new friends to be turned into hovercrafts' do
      new_job_data = StreamerFriendsCreate.work_data streamer, new_friend_ids
      StreamerFriendsCreate.should_receive(:schedule).with new_job_data
      TwitterHandler.streamer_friends_new streamer
    end
  end
end