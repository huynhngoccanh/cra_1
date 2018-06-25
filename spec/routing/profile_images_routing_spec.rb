require "rails_helper"

RSpec.describe ProfileImagesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/profile_images").to route_to("profile_images#index")
    end

    it "routes to #new" do
      expect(:get => "/profile_images/new").to route_to("profile_images#new")
    end

    it "routes to #show" do
      expect(:get => "/profile_images/1").to route_to("profile_images#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/profile_images/1/edit").to route_to("profile_images#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/profile_images").to route_to("profile_images#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/profile_images/1").to route_to("profile_images#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/profile_images/1").to route_to("profile_images#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/profile_images/1").to route_to("profile_images#destroy", :id => "1")
    end

  end
end
