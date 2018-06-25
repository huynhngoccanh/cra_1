require 'rails_helper'

RSpec.describe "profile_images/new", type: :view do
  before(:each) do
    assign(:profile_image, ProfileImage.new(
      :image => "MyString",
      :user => nil
    ))
  end

  it "renders new profile_image form" do
    render

    assert_select "form[action=?][method=?]", profile_images_path, "post" do

      assert_select "input#profile_image_image[name=?]", "profile_image[image]"

      assert_select "input#profile_image_user_id[name=?]", "profile_image[user_id]"
    end
  end
end
