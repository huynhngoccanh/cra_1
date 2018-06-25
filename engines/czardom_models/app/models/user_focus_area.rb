class UserFocusArea < ActiveRecord::Base
  belongs_to :user
  belongs_to :focus_area

  def as_json(options={})
    {
      :id => id,
      :user_id => user_id,
      :focus_area_id => focus_area_id,
      :created_at => created_at.to_date,
      :updated_at => updated_at.to_date
    }
  end
end
