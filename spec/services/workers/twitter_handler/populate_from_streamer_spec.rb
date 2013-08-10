require 'spec_helper'
require 'sidekiq/testing'

describe :populate_from_streamer do

  shared_examples_for 'a worker to populate_from_streamer' do
    it 'calls the Twitter.friends API' do
      Twitter.should_receive(:friend_ids).with(streamer.tid, {cursor: next_cursor_page})
      TwitterHandler.populate_from_streamer streamer, next_cursor_page
    end

    describe 'batch the friend ids' do # to match the limit(100) when calling Twitter.users
      let (:batches_of_ids) { new_friend_ids.each_slice(TWITTER_FETCH_USERS_BATCH_SIZE).to_a }
      it 'schedules PopulateFromStreamerFriends in batches of friend ids' do
        batches_of_ids.each do |ids|
          new_job_data = PopulateFromStreamerFriends.work_data streamer, ids
          PopulateFromStreamerFriends.should_receive(:schedule).with new_job_data
        end
        TwitterHandler.populate_from_streamer streamer, next_cursor_page
      end
      it 'schedules PopulateFromStreamerFriends for each batch' do
        expect {
          TwitterHandler.populate_from_streamer streamer, next_cursor_page
        }.to change(PopulateFromStreamerFriends.jobs, :size).by(batches_of_ids.size)
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
    it_behaves_like 'a worker to populate_from_streamer'
  end

  context 'Process a page with a large number of friends in batches' do
    let (:friend_tids)      { (1000..1310).to_a }
    it_behaves_like 'a worker to populate_from_streamer'
  end

  context 'Processes multiple pages of friends' do
    let (:next_cursor_page)        { 1 }
    it_behaves_like 'a worker to populate_from_streamer'
    it 'schedules another job to process the next page' do
      next_job_data = PopulateFromStreamer.work_data streamer, next_cursor_page
      PopulateFromStreamer.should_receive(:schedule).with next_job_data
      TwitterHandler.populate_from_streamer streamer, next_cursor_page
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

    it_behaves_like 'a worker to populate_from_streamer'
    it 'schedules only the new friends to be turned into hovercrafts' do
      new_job_data = PopulateFromStreamerFriends.work_data streamer, new_friend_ids
      PopulateFromStreamerFriends.should_receive(:schedule).with new_job_data
      TwitterHandler.populate_from_streamer streamer
    end
  end
end