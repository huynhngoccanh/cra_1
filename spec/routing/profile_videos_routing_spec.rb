require "rails_helper"

RSpec.describe ProfileVideosController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/profile_videos").to route_to("profile_videos#index")
    end

    it "routes to #new" do
      expect(:get => "/profile_videos/new").to route_to("profile_videos#new")
    end

    it "routes to #show" do
      expect(:get => "/profile_videos/1").to route_to("profile_videos#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/profile_videos/1/edit").to route_to("profile_videos#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/profile_videos").to route_to("profile_videos#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/profile_videos/1").to route_to("profile_videos#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/profile_videos/1").to route_to("profile_videos#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/profile_videos/1").to route_to("profile_videos#destroy", :id => "1")
    end

  end
end
