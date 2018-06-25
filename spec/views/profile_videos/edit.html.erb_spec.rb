require 'rails_helper'

RSpec.describe "profile_videos/edit", type: :view do
  before(:each) do
    @profile_video = assign(:profile_video, ProfileVideo.create!(
      :video => "MyString",
      :user => nil
    ))
  end

  it "renders the edit profile_video form" do
    render

    assert_select "form[action=?][method=?]", profile_video_path(@profile_video), "post" do

      assert_select "input#profile_video_video[name=?]", "profile_video[video]"

      assert_select "input#profile_video_user_id[name=?]", "profile_video[user_id]"
    end
  end
end
