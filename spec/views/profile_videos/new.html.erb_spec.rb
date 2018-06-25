require 'rails_helper'

RSpec.describe "profile_videos/new", type: :view do
  before(:each) do
    assign(:profile_video, ProfileVideo.new(
      :video => "MyString",
      :user => nil
    ))
  end

  it "renders new profile_video form" do
    render

    assert_select "form[action=?][method=?]", profile_videos_path, "post" do

      assert_select "input#profile_video_video[name=?]", "profile_video[video]"

      assert_select "input#profile_video_user_id[name=?]", "profile_video[user_id]"
    end
  end
end
