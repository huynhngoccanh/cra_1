class Advertisement < ActiveRecord::Base
  mount_base64_uploader :image, AdvertisementUploader
end
