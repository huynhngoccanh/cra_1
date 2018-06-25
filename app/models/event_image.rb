class EventImage < ActiveRecord::Base
  belongs_to :event
  mount_base64_uploader :image, ImageUploader
end
