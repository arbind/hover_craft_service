require 'spec_helper'

describe :scheduled_workers do

  shared_examples_for 'a scheduled worker' do
    specify { expect(subject::perform_after.to_i).to be > rate }
    it '.work_data' do
      if args.any?
        expect(subject::work_data(*args)).to eq work_data
      end
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

  let (:hover_craft_resolve_url_args)         { [hover_craft, url_attribute] }
  let (:hover_craft_resolve_url_work_data)    {{
    "hover_craft_id"=> hover_craft.id.to_s,
    "url_attribute" => url_attribute
  }}

  let (:populate_from_streamer_args) { [streamer, page]}
  let (:populate_from_streamer_work_data) {{
    "streamer_id"=> streamer.id.to_s,
    "page"        => page
  }}

  let (:populate_from_streamer_friends_args) { [streamer, ids] }
  let (:populate_from_streamer_friends_work_data) {{
    "streamer_id"=> streamer.id.to_s,
    "friend_ids"  => ids
  }}

  describe PopulateHoverCrafts do
    subject          { PopulateHoverCrafts }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateHoverCraft do
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { PopulateHoverCraft }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateFromStreamers do
    subject          { PopulateFromStreamer }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateFromStreamer do
    let (:args)      { populate_from_streamer_args }
    let (:work_data) { populate_from_streamer_work_data }
    subject          { PopulateFromStreamer }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateFromStreamerFriends do
    let (:args)      { populate_from_streamer_friends_args }
    let (:work_data) { populate_from_streamer_friends_work_data }
    subject          { PopulateFromStreamerFriends }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateYelpCraft do
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { PopulateYelpCraft }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateTwitterCraft do
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { PopulateTwitterCraft }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateFacebookCraft do
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { PopulateFacebookCraft }
    it_behaves_like 'a scheduled worker'
  end

  describe PopulateWebsiteCraft do
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { PopulateWebsiteCraft }
    it_behaves_like 'a scheduled worker'
  end

  describe HoverCraftResolveUrl do
    let (:args)      { hover_craft_resolve_url_args }
    let (:work_data) { hover_craft_resolve_url_work_data }
    subject          { HoverCraftResolveUrl }
    it_behaves_like 'a scheduled worker'
  end

  describe WebsiteScanForLinks do
    let (:args)      { hover_craft_args }
    let (:work_data) { hover_craft_work_data }
    subject          { WebsiteScanForLinks }
    it_behaves_like 'a scheduled worker'
  end

end