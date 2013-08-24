require 'spec_helper'

describe HoverCraft do

  context :relations do
    describe '#tweet_streamer' do
      let (:screen_name) { 'govinda' }
      let!(:streamer)    { create :tweet_streamer, screen_name: screen_name}
      let!(:subject)     { create :hover_craft, tweet_streamer: streamer }
      it '.crafted returns HoverCraft with a craft_id' do
        expect(subject.tweet_streamer.screen_name).to eq screen_name
      end
    end
  end

  context :average_craft_fit_score_before_save do
    context 'given only twitter and facebook' do
      let!(:hover_craft)       { create :hover_craft, :twitter, :facebook, twitter_fit_score: 7, facebook_fit_score: 9  }
      it 'it averages only for provider_fit_scores that are present' do
        expect(hover_craft.craft_fit_score).to eq 8
      end
    end
    context 'given only twitter, yelp and website' do
      let!(:hover_craft)       { create :hover_craft, :twitter, :yelp, :website, twitter_fit_score: 7, yelp_fit_score: 1, website_fit_score:1 }
      it 'it averages only for provider_fit_scores that are present' do
        expect(hover_craft.craft_fit_score).to eq 3
      end
    end
    context 'given a complete hovercraft' do
      let!(:hover_craft)       { create :hover_craft, :twitter, :facebook, :yelp, :website, twitter_fit_score: 7,  facebook_fit_score: 7, yelp_fit_score: 9, website_fit_score:9 }
      it 'it averages all provider_fit_scores' do
        expect(hover_craft.craft_fit_score).to eq 8
      end
    end
  end

  context :provider_fit_scores do
    describe :twitter_fit_score do
      context 'given a streamer and a twitter_craft' do
        it 'is FIT_auto_approved'
      end
      context 'given a yelp_craft' do
        context 'given matching names' do
          it 'is FIT_absolute'
        end
        context 'given matching website_urls' do
          it 'is FIT_absolute'
        end
      end
    end
  end

  context :crafted do
    describe 'crafted scopes' do
      let!(:existant)     { create_list :hover_craft, 3, craft_id: '123' }
      let!(:non_existant) { create_list :hover_craft, 4, craft_id: nil }
      it '.crafted returns HoverCraft with a craft_id' do
        expect(HoverCraft.crafted.count).to eq existant.count
        expect(HoverCraft.crafted).to include *existant
      end
      it '.uncrafted returns HoverCraft with a craft_id' do
        expect(HoverCraft.uncrafted.count).to eq non_existant.count
        expect(HoverCraft.uncrafted).to include *non_existant
      end
    end
  end

  context :web_crafted do

    describe 'twelps scopes' do
      let!(:complete)     { create_list :complete_hover_craft, 3 }
      let!(:twitter_only) { create_list :twitter_hover_craft, 3 }
      let!(:yelp_only)    { create_list :yelp_hover_craft, 3}
      it '.twelp returns HoverCraft with both yelp_id and twitter_id' do
        expect(HoverCraft.twelps.count).to eq complete.count
        expect(HoverCraft.twelps).to include *complete
      end
    end
    describe 'yelp scopes' do
      let!(:existant)     { create_list :hover_craft, 3, yelp_id: '123' }
      let!(:non_existant) { create_list :hover_craft, 4, yelp_id: nil }
      it '.with_yelp returns HoverCraft with a yelp_id' do
        expect(HoverCraft.with_yelp.count).to eq existant.count
        expect(HoverCraft.with_yelp).to include *existant
      end
      it '.without_yelp returns HoverCraft without yelp_id' do
        expect(HoverCraft.without_yelp.count).to eq non_existant.count
        expect(HoverCraft.without_yelp).to include *non_existant
      end
    end
    describe 'twitter scopes' do
      let!(:existant)     { create_list :hover_craft, 3, twitter_id: '123' }
      let!(:non_existant) { create_list :hover_craft, 4, twitter_id: nil }
      it '.with_twitter returns HoverCraft with a twitter_id' do
        expect(HoverCraft.with_twitter.count).to eq existant.count
        expect(HoverCraft.with_twitter).to include *existant
      end
      it '.without_twitter returns HoverCraft without twitter_id' do
        expect(HoverCraft.without_twitter.count).to eq non_existant.count
        expect(HoverCraft.without_twitter).to include *non_existant
      end
    end
    describe 'website scopes' do
      let!(:existant)     { create_list :hover_craft, 3, website_url: '123' }
      let!(:non_existant) { create_list :hover_craft, 4, website_url: nil }
      it '.with_website returns HoverCraft with a website_url' do
        expect(HoverCraft.with_website.count).to eq existant.count
        expect(HoverCraft.with_website).to include *existant
      end
      it '.without_website returns HoverCraft without website_url' do
        expect(HoverCraft.without_website.count).to eq non_existant.count
        expect(HoverCraft.without_website).to include *non_existant
      end
    end
    describe 'facebook scopes' do
      let!(:existant)     { create_list :hover_craft, 3, facebook_id: '123' }
      let!(:non_existant) { create_list :hover_craft, 4, facebook_id: nil }
      it '.with_facebook returns HoverCraft with a facebook_id' do
        expect(HoverCraft.with_facebook.count).to eq existant.count
        expect(HoverCraft.with_facebook).to include *existant
      end
      it '.without_facebook returns HoverCraft without facebook_id' do
        expect(HoverCraft.without_facebook.count).to eq non_existant.count
        expect(HoverCraft.without_facebook).to include *non_existant
      end
    end
  end

  context :missing_web_crafts do
    let!(:complete_hc)         { create_list :complete_hover_craft, 3 }
    let!(:missing_yelp_hc)     { create_list :no_yelp_hover_craft, 3 }
    let!(:missing_twitter_hc)  { create_list :no_twitter_hover_craft, 3 }
    let!(:missing_facebook_hc) { create_list :no_facebook_hover_craft, 3 }
    let!(:missing_website_hc)  { create_list :no_website_hover_craft, 3 }
    let (:something_missing)   { missing_yelp_hc + missing_twitter_hc + missing_facebook_hc + missing_website_hc }
    it '.with_missing_web_craft returns HoverCraft with any web craft missing' do
      expect(HoverCraft.with_missing_web_craft.count).to eq something_missing.count
      expect(HoverCraft.with_missing_web_craft).to include *something_missing
    end
  end

  context :flagged do
    describe 'flagged scope' do
      let!(:nil_hover_craft)    { create_list :hover_craft, 4, flag_this: nil }
      let!(:true_hover_craft)   { create_list :hover_craft, 3, flag_this: true }
      let!(:false_hover_craft)  { create_list :hover_craft, 4, flag_this: false }
      let (:un_hover_craft)     { nil_hover_craft + false_hover_craft }
      it '.flagged returns flagged HoverCraft' do
        expect(HoverCraft.flagged.count).to eq true_hover_craft.count
        expect(HoverCraft.flagged).to include *true_hover_craft
      end
      it '.unflagged returns flagged HoverCraft' do
        expect(HoverCraft.unflagged.count).to eq un_hover_craft.count
        expect(HoverCraft.unflagged).to include *un_hover_craft
      end
    end
    describe 'skipped scope' do
      let!(:nil_hover_craft)    { create_list :hover_craft, 4, skip_this: nil }
      let!(:true_hover_craft)   { create_list :hover_craft, 3, skip_this: true }
      let!(:false_hover_craft)  { create_list :hover_craft, 4, skip_this: false }
      let (:un_hover_craft)     { nil_hover_craft + false_hover_craft }
      it '.skipped returns skipped HoverCraft' do
        expect(HoverCraft.skipped.count).to eq true_hover_craft.count
        expect(HoverCraft.skipped).to include *true_hover_craft
      end
      it '.unskipped returns skipped HoverCraft' do
        expect(HoverCraft.unskipped.count).to eq un_hover_craft.count
        expect(HoverCraft.unskipped).to include *un_hover_craft
      end
    end
  end

  context 'fit score scopes' do
    let!(:need_to_explore_hc) { create_list :hover_craft, 3, twitter_fit_score: HoverCraft::FIT_need_to_explore }
    let!(:check_manually_hc)  { create_list :hover_craft, 3, twitter_fit_score: HoverCraft::FIT_check_manually }
    let!(:missing_craft_hc)   { create_list :hover_craft, 3, twitter_fit_score: HoverCraft::FIT_missing_craft }
    let!(:zero_fit_hc)        { create_list :hover_craft, 3, twitter_fit_score: HoverCraft::FIT_zero }
    let!(:neutral_fit_hc)     { create_list :hover_craft, 3, twitter_fit_score: HoverCraft::FIT_neutral }
    let!(:absolute_fit_hc)    { create_list :hover_craft, 3, twitter_fit_score: HoverCraft::FIT_absolute }

    it '.need_to_explore_hc' do
     expect(HoverCraft.need_to_explore(:twitter).count).to eq need_to_explore_hc.count
     expect(HoverCraft.need_to_explore(:twitter)).to include *need_to_explore_hc
    end
    it '.check_manually_hc' do
     expect(HoverCraft.check_manually(:twitter).count).to eq check_manually_hc.count
     expect(HoverCraft.check_manually(:twitter)).to include *check_manually_hc
    end
    it '.missing_craft_hc' do
     expect(HoverCraft.missing_craft(:twitter).count).to eq missing_craft_hc.count
     expect(HoverCraft.missing_craft(:twitter)).to include *missing_craft_hc
    end
    it '.zero_fit_hc' do
     expect(HoverCraft.zero_fit(:twitter).count).to eq zero_fit_hc.count
     expect(HoverCraft.zero_fit(:twitter)).to include *zero_fit_hc
    end
    it '.neutral_fit_hc' do
     expect(HoverCraft.neutral_fit(:twitter).count).to eq neutral_fit_hc.count
     expect(HoverCraft.neutral_fit(:twitter)).to include *neutral_fit_hc
    end
    it '.absolute_fit_hc' do
     expect(HoverCraft.absolute_fit(:twitter).count).to eq absolute_fit_hc.count
     expect(HoverCraft.absolute_fit(:twitter)).to include *absolute_fit_hc
    end
  end

  context '#twitter_href' do
    let (:screen_name) { '_my_twitter_name' }
    let (:hover_craft) { build :complete_hover_craft, twitter_screen_name: screen_name  }
    it 'calculates twitter_href' do
      expect(hover_craft.twitter_href).to eq "https://twitter.com/#{screen_name}"
    end
  end
  context '#populated?' do
    context 'for complete hover craft' do
      let (:hover_craft) { create :complete_hover_craft }
      it 'returns true' do
        expect(hover_craft.populated?).to be_true
      end
    end

    context 'for incomplete hover craft' do
      [
        :no_yelp_hover_craft,
        :no_twitter_hover_craft,
        :no_website_hover_craft,
        :no_facebook_hover_craft
      ].each do |missing_craft|
        it "returns false when there is #{missing_craft}" do
          hover_craft = build missing_craft
          expect(hover_craft.populated?).to be_false
        end
      end
    end
  end
end