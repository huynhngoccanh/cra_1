class TaggedUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :forem_post, :class_name => 'Forem::Post'
end
