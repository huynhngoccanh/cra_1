class Job < ActiveRecord::Base
  include HasAddress
  mount_base64_uploader :image, ImageUploader

  default_scope lambda { where(deleted: false) }

  has_address :address
  belongs_to :user
  validates :job_summery, length: {minimum: 0, maximum: 1000}, allow_blank: true
  validates :summery_of_experience, length: {minimum: 0, maximum: 500}, allow_blank: true
  has_one :job_subscription

  scope :active_jobs, -> { where("job_end_on >= '#{Time.current}'") }

  def full_name
    [company, title].join(' - ')
  end

  # Finds all current job openings for the current date.
  #
  #   Job.current #=> [Job, Job, Job, ...]
  def self.current
    where('job_start_on < ?', Date.today)
    .where('job_end_on > ?', Date.today)
  end

  def location
    if address.present?
      "%s, %s" % [address.city, address.state]
    else
      "N/A"
    end
  end

  def as_json(options={})
    {
      :id => id,
      :title => title ,
      :description => description ,
      :avatar => avatar,
      :skills => summery_of_experience,
      :contact_email => contact_email,
      :job_end_on => job_end_on,
      :user_id => user_id,
      :username => user.full_name,
      :usertitle => user.title,
      :isCharterCzar => user.charter_member?,
      :plan_id => job_subscription.present? ? job_subscription.job_plan_id : "",
      :created_at => created_at,
      :updated_at => updated_at
    }
  end

  def avatar
    {
      small: image_url(:small),
      thumb: image_url(:thumb),
      large: image_url(:large)
    }
  end 

  

end
