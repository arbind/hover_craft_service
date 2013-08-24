require 'spec_helper'
require 'sidekiq/testing'

describe :populate_from_streamer_friends do

  shared_examples_for 'a worker that create HoverCrafts for new streamer friends' do
    let!(:streamer)             { create :tweet_streamer }
    let (:twitter_users)        { create_twitter_users(first_batch_of_tids) }
    let (:twitter_options)      { {} }
    let (:new_friend_ids)       { new_friend_tids.map &:to_s }
    let (:batches_of_ids)       { new_friend_ids.each_slice(TWITTER_FETCH_USERS_BATCH_SIZE).to_a }
    let (:first_batch_of_ids)   { batches_of_ids.first }
    let (:first_batch_of_tids)  { first_batch_of_ids.map &:to_i}

    before do
      Twitter.stub(:users).with(first_batch_of_tids, twitter_options).and_return twitter_users
    end

    describe 'batch the ids' do #  to match the limit(100) for a call to Twitter.users([...])
      it 'reschedules all but the 1st batch' do
        remaining_batches_of_ids = batches_of_ids[1..-1]
        remaining_batches_of_ids.each do |ids|
          new_job_data = PopulateFromStreamerFriends.work_data streamer, ids
          PopulateFromStreamerFriends.should_receive(:schedule).with new_job_data
        end
        TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
      end

      context 'for the first batch of ids' do
        it 'retrieves twitter profiles' do
          options = {}
          Twitter.should_receive(:users).with(first_batch_of_tids, twitter_options)
          TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
        end
        it 'creates a new HoverCraft for each twitter profile' do
          expect {
            TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
          }.to change(HoverCraft, :count).by(first_batch_of_ids.size)
        end
        it 'sets the tweet_streamer for the new HoverCraft' do
          TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
          HoverCraft.each do |hc|
            expect(first_batch_of_ids).to include hc.twitter_id
            expect(hc.tweet_streamer.id).to eq streamer.id
          end
        end
        it 'sets the twitter_fit_score to FIT_absolute' do
          TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
          HoverCraft.each do |hc|
            expect(hc.twitter_fit_score).to eq HoverCraft::FIT_absolute
          end
        end
        it 'automatically promotes the HoverCraft to be craftable' do
          TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
          HoverCraft.each do |hc|
            expect(hc.craftable).to be_true
          end
        end
        it 'schedules ResolveUrl jobs for each new HoverCraft (to resolve t.co)' do
          expect {
            TwitterHandler.populate_from_streamer_friends streamer, new_friend_ids
          }.to change(HoverCraftResolveUrl.jobs, :size).by(first_batch_of_ids.size)
        end
      end
    end
  end

  let (:new_friend_tids)    { (1000..1010).to_a }

  context 'Process all streamer friends' do
    it_behaves_like 'a worker that create HoverCrafts for new streamer friends'
  end
  context 'Given a large number of new friends' do
    let (:new_friend_tids)  { (1000..1250).to_a }
    it_behaves_like 'a worker that create HoverCrafts for new streamer friends'
  end
end