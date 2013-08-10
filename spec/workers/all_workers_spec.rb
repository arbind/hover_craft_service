require 'spec_helper'

describe :scheduled_workers do

  shared_examples_for 'a scheduled worker' do
    specify { expect(subject::perform_after.to_i).to be > rate }
    it '.work_data' do
      expect(subject::work_data(*args)).to eq work_data
    end
  end

  let (:rate)           { 0 }
  let (:streamer)       { create :tweet_streamer }
  let (:hover_craft)    { create :hover_craft }
  let (:page)           { 3 }
  let (:ids)            { (1..8).to_a }
  let (:url)            { 'http://i.am.me' }
  let (:url_attribute)  { :twitter_website_url }

  let (:args)           { [] }
  let (:work_data)      { {} }

  let (:hover_craft_args)         { [hover_craft] }
  let (:hover_craft_work_data)    {{
    "hover_craft_id"=> hover_craft.id.to_s
  }}

  let (:resolve_url_args)         { [hover_craft, url_attribute] }
  let (:resolve_url_work_data)    {{
    "hover_craft_id"=> hover_craft.id.to_s,
    "url_attribute" => url_attribute
  }}

  let (:streamer_friends_new_args) { [streamer, page]}
  let (:streamer_friends_new_work_data) {{
    "streamer_id"=> streamer.id.to_s,
    "page"        => page
  }}

  let (:streamer_friends_create_args) { [streamer, ids] }
  let (:streamer_friends_create_work_data) {{
    "streamer_id"=> streamer.id.to_s,
    "friend_ids"  => ids
  }}

  describe MissingWebCrafts do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { MissingWebCrafts }
    it_behaves_like 'a scheduled worker'
  end

  describe MissingWebCraftsNew do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { MissingWebCraftsNew }
    it_behaves_like 'a scheduled worker'
  end

  describe ResolveUrl do
    let (:rate)      { 0 }
    let (:args)      { resolve_url_args }
    let (:work_data) { resolve_url_work_data }
    subject          { ResolveUrl }
    it_behaves_like 'a scheduled worker'
  end

  describe StreamerFriends do
    let (:rate)      { 0 }
    subject          { StreamerFriends }
    it_behaves_like 'a scheduled worker'
  end

  describe StreamerFriendsCreate do
    let (:rate)      { 0 }
    let (:args)      { streamer_friends_create_args }
    let (:work_data) { streamer_friends_create_work_data }
    subject          { StreamerFriendsCreate }
    it_behaves_like 'a scheduled worker'
  end

  describe StreamerFriendsNew do
    let (:rate)      { 0 }
    let (:args)      { streamer_friends_new_args }
    let (:work_data) { streamer_friends_new_work_data }
    subject          { StreamerFriendsNew }
    it_behaves_like 'a scheduled worker'
  end

  describe TwitterCraftCreate do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { TwitterCraftCreate }
    it_behaves_like 'a scheduled worker'
  end

  describe TwitterCraftNew do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { TwitterCraftNew }
    it_behaves_like 'a scheduled worker'
  end

  describe WebsiteLinks do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { WebsiteLinks }
    it_behaves_like 'a scheduled worker'
  end

  describe YelpCraftCreate do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { YelpCraftCreate }
    it_behaves_like 'a scheduled worker'
  end

  describe YelpCraftNew do
    let (:rate)      { 0 }
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { YelpCraftNew }
    it_behaves_like 'a scheduled worker'
  end

end