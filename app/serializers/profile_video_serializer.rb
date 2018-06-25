class ProfileVideoSerializer < ActiveModel::Serializer
  attributes :id, :video
  has_one :user
end
