class ProfileImage < ActiveRecord::Base
  belongs_to :user
  mount_uploader :image, ImageUploader
  validate :user_quota, :on => :create  

	private 
	  def user_quota
	   if user.profile_images.count >= 10
	     errors.add(:base, "You can not add more than 10 images")
	   end
	  end
end
