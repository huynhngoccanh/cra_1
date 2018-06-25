require 'rails_helper'

RSpec.describe "profile_videos/index", type: :view do
  before(:each) do
    assign(:profile_videos, [
      ProfileVideo.create!(
        :video => "Video",
        :user => nil
      ),
      ProfileVideo.create!(
        :video => "Video",
        :user => nil
      )
    ])
  end

  it "renders a list of profile_videos" do
    render
    assert_select "tr>td", :text => "Video".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
