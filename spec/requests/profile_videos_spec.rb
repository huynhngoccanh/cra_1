require 'rails_helper'

RSpec.describe "ProfileVideos", type: :request do
  describe "GET /profile_videos" do
    it "works! (now write some real specs)" do
      get profile_videos_path
      expect(response).to have_http_status(200)
    end
  end
end
