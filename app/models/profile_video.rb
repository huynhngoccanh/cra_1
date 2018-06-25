class ProfileVideo < ActiveRecord::Base
  belongs_to :user
  YT_LINK_FORMAT = /(http:\/\/|https:\/\/|)(www.)?(youtu(be\.com|\.be|be\.com))\/(video\/|embed\/|watch\?v=|v\/)?([A-Za-z0-9._%-]*)(\&\S+)?/

	validates :video, presence: true, format: YT_LINK_FORMAT
	# attr_accessor :uid

	validate :user_quota, :on => :create  

	before_save -> do
	  uid = video.match(YT_LINK_FORMAT)
	  self.uid = uid[6] if uid && uid[6]

	  if self.uid.to_s.length != 11
	    self.errors.add(:video, 'is invalid.')
	    false
	  elsif self.class.where(uid: self.video).any?
	    self.errors.add(:video, 'is not unique.')
	    false
	  else
	    true
	  end
	end

	private 
	  def user_quota
	   if user.profile_videos.count >= 5
	     errors.add(:base, "You can not add more than 5 videos")
	   end
	  end
end
