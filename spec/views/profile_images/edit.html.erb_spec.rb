require 'rails_helper'

RSpec.describe "profile_images/edit", type: :view do
  before(:each) do
    @profile_image = assign(:profile_image, ProfileImage.create!(
      :image => "MyString",
      :user => nil
    ))
  end

  it "renders the edit profile_image form" do
    render

    assert_select "form[action=?][method=?]", profile_image_path(@profile_image), "post" do

      assert_select "input#profile_image_image[name=?]", "profile_image[image]"

      assert_select "input#profile_image_user_id[name=?]", "profile_image[user_id]"
    end
  end
end
