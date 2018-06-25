class EventVideo < ActiveRecord::Base
  belongs_to :event
  YT_LINK_FORMAT = /(http:\/\/|https:\/\/|)(www.)?(youtu(be\.com|\.be|be\.com))\/(video\/|embed\/|watch\?v=|v\/)?([A-Za-z0-9._%-]*)(\&\S+)?/

	validates :video_url, format: YT_LINK_FORMAT

	before_save -> do
	  uid = video_url.match(YT_LINK_FORMAT)
	  self.uid = uid[6] if uid && uid[6]

	  if self.uid.to_s.length != 11
	    self.errors.add(:video_url, 'is invalid.')
	    false
	  # elsif EventVideo.where(uid: self.uid).any?
	  #   self.errors.add(:video_url, 'is not unique.')
	  #   false
	  else
	    true
	  end
	end

end
