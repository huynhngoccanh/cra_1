class UserSegment < ActiveRecord::Base
  default_scope lambda { order(:position, :name) }

  has_ancestry

  has_many :primary_users, class_name: 'User', foreign_key: :primary_segment_id
  has_many :secondary_users, class_name: 'User', foreign_key: :secondary_segment_id

  has_many :user_segments, foreign_key: 'ancestry'
  # has_many :user_segmentations
  # has_many :users, through: :user_segmentations
  accepts_nested_attributes_for :user_segments, reject_if: lambda { |a| a['name'].blank? }, allow_destroy: true

  def as_json(options={})
    {
      :id => id,
      :position => position,
      :name => name,
      :ancestry => ancestry,
      :created_at => created_at.to_date,
      :updated_at => updated_at.to_date
    }
  end

end
