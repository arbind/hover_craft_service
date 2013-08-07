require 'spec_helper'
require 'sidekiq/testing'

describe WorkerCreateHoverCraftsForNewStreamerFriends do

  def create_twitter_profile(i)
    TwitterApi::TwitterProfile.new({
      id_str: "#{i}",
      name: "Prince the #{i}th",
      screen_name: "tweeter-#{i}"
    })
  end

  def create_twitter_profiles(ids)
    ids.map{ |id| create_twitter_profile(id) }
  end

  shared_examples_for 'a worker to CreateHoverCraftsForNewStreamerFriends' do
    describe 'Batch the ids' do #  to match the limit(100) for a call to Twitter.users([...])
      it 'reschedules all but the 1st batch' do
        remaining_batches_of_ids = batches_of_ids[1..-1]
        remaining_batches_of_ids.each do |ids|
          new_job_data = WorkerCreateHoverCraftsForNewStreamerFriends.work_data streamer.id, ids
          WorkerCreateHoverCraftsForNewStreamerFriends.should_receive(:schedule).with new_job_data
        end
        subject.perform work_data
      end

      context 'for the first batch of ids' do
        it 'retrieves twitter profiles' do
          options = {}
          Twitter.should_receive(:users).with(first_batch_of_tids, twitter_options)
          subject.perform work_data
        end
        it 'creates a new HoverCraft for each twitter profile' do
          expect {
            subject.perform work_data
          }.to change(HoverCraft, :count).by(first_batch_of_ids.size)
        end
        it 'sets the tweet_streamer for the new HoverCraft' do
          subject.perform work_data
          HoverCraft.each do |hc|
            expect(hc.tweet_streamer.id).to eq streamer.id
          end
        end
        it 'schedules WorkerResolveHoverCraftUrl jobs for each new HoverCraft (to resolve t.co)' do
          expect {
            subject.perform work_data
          }.to change(WorkerResolveHoverCraftUrl.jobs, :size).by(first_batch_of_ids.size)
        end
      end
    end
  end

  let (:subject)            { WorkerCreateHoverCraftsForNewStreamerFriends.new }
  let (:work_data)          { WorkerCreateHoverCraftsForNewStreamerFriends.work_data streamer.id, new_friend_ids}
  let (:new_friend_tids)    { (1000..1010).to_a }
  let (:new_friend_ids)     { new_friend_tids.map &:to_s }

  let!(:streamer)           { create :tweet_streamer }
  let (:twitter_profiles)   { create_twitter_profiles(first_batch_of_tids) }
  let (:batches_of_ids)     { new_friend_ids.each_slice(TWITTER_FETCH_USERS_BATCH_SIZE).to_a }
  let (:first_batch_of_ids) { batches_of_ids.first }
  let (:first_batch_of_tids){ first_batch_of_ids.map &:to_i}
  let (:twitter_options)    { {} }
  before do
    Twitter.stub(:users).with(first_batch_of_tids, twitter_options).and_return twitter_profiles
  end

  context 'Process all streamer friends' do
    it_behaves_like 'a worker to CreateHoverCraftsForNewStreamerFriends'
  end
  context 'Given a large number of new friends' do
    let (:new_friend_tids)  { (1000..1250).to_a }
    it_behaves_like 'a worker to CreateHoverCraftsForNewStreamerFriends'
  end
end