class Media < ActiveRecord::Base
  mount_base64_uploader :media, MediaUploader
end
