class ProfileImageSerializer < ActiveModel::Serializer
  attributes :id, :image
  has_one :user
end
