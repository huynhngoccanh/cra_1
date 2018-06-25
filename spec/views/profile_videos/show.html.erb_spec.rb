require 'rails_helper'

RSpec.describe "profile_videos/show", type: :view do
  before(:each) do
    @profile_video = assign(:profile_video, ProfileVideo.create!(
      :video => "Video",
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Video/)
    expect(rendered).to match(//)
  end
end
