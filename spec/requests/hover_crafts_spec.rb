require 'spec_helper'

describe "HoverCrafts" do
  describe "GET /hover_crafts" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get hover_crafts_path
      response.status.should be(200)
    end
  end
end
