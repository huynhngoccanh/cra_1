require 'rails_helper'

RSpec.describe "profile_images/show", type: :view do
  before(:each) do
    @profile_image = assign(:profile_image, ProfileImage.create!(
      :image => "Image",
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Image/)
    expect(rendered).to match(//)
  end
end
