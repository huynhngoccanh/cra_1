require 'rails_helper'

RSpec.describe "ProfileImages", type: :request do
  describe "GET /profile_images" do
    it "works! (now write some real specs)" do
      get profile_images_path
      expect(response).to have_http_status(200)
    end
  end
end
