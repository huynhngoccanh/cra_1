require 'rails_helper'

RSpec.describe "profile_images/index", type: :view do
  before(:each) do
    assign(:profile_images, [
      ProfileImage.create!(
        :image => "Image",
        :user => nil
      ),
      ProfileImage.create!(
        :image => "Image",
        :user => nil
      )
    ])
  end

  it "renders a list of profile_images" do
    render
    assert_select "tr>td", :text => "Image".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
