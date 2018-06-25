class SponsorLogo < ActiveRecord::Base
  has_many :group_sponsors, dependent: :destroy
  has_many :groups, through: :group_sponsors
  
  extend FriendlyId

  friendly_id :name, use: :slugged
  
  validates :name, presence: true

  mount_base64_uploader :image, SponsorLogoUploader

  enum default_status: [ :normal, :default ]
end
