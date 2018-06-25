class User < ActiveRecord::Base
  acts_as_token_authenticatable
  include AASM
  include AlgoliaSearch
  include RoleModel
  include HasAddress
  include UserRoles

  # EXPORT_ATTRIBUTES = [:id, :first_name, :last_name, :slug_url, :address_city, :address_state, :created_at, :email, :charter_member?, :total_donated]
 EXPORT_ATTRIBUTES = [:id, :first_name, :last_name, :slug_url, :address_city, :address_state, :created_at, :email]
  recommends :groups

  extend FriendlyId
  friendly_id :full_name, use: :slugged

  before_save :parameterize_slug

  acts_as_liker
  acts_as_messageable
  acts_as_commentable
  has_many :forem_topics
  has_many :sales, class_name: 'Payola::Sale', as: :owner
  has_one :subscription, class_name: 'Payola::Subscription', as: :owner
  has_many :jobs, dependent: :destroy
  has_many :tagged_users
  has_many :subscriptions

  STATUS = ["Pending", "Approve", "Decline"]

  def has_subscription?
    subscription.present?
  end

  aasm column: :state do
    state :onboarding_groups
    state :onboarding_users
    state :onboarding_clients
    state :almost_finish
    state :complete

    state :active, initial: true
    state :banned

    event :activate do
      transitions :to => :active
    end

    event :ban do
      transitions :to => :banned
    end
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, #, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  devise :lastseenable

  after_destroy :delete_posts

  # PROFILE IMAGES
  mount_base64_uploader :image, ImageUploader
  mount_base64_uploader :cover_photo, CoverPhotoUploader

  mount_uploader :resume, ResumeUploader

  # ASSOCIATIONS
  has_many :activities, dependent: :destroy
  has_many :posts, as: :postable, dependent: :destroy
  has_many :notifications, lambda { order('created_at desc') }, as: :receiver, dependent: :destroy

  has_many :following, class_name: 'UserFollower', dependent: :destroy
  has_many :following_users, through: :following, source: :following

  has_many :followers, class_name: 'UserFollower', foreign_key: :following_id, dependent: :destroy

  has_many :group_users
  has_many :groups, through: :group_users

  has_many :clients, lambda { order(:position) }, class_name: 'UserClient', dependent: :destroy
  accepts_nested_attributes_for :clients, reject_if: proc { |c| c['name'].blank? }, allow_destroy: true

  has_many :event_users
  has_many :events, lambda { where('event_users.going = true and event_users.not_going = false') }, through: :event_users

  has_many :event_followers
  has_many :event_followings, through: :event_followers, source: :event

  has_address :address

  has_many :reputation, class_name: 'UserReputation'

  has_many :user_taggings
  has_many :user_tags, through: :user_taggings

  belongs_to :primary_segment, class_name: 'UserSegment'

  has_many :user_segmentations
  has_many :user_segments, through: :user_segmentations

  has_many :user_focus_areas
  has_many :focus_areas, through: :user_focus_areas

  has_many :profile_images
  has_many :profile_videos

  accepts_nested_attributes_for :address, :user_segments, :focus_areas, :profile_images, :profile_videos

  algoliasearch if: :indexable?, per_environment: true, disable_indexing: Rails.env.test? do
    attribute :full_name, :email, :work, :education, :slug, :slug_url

    attribute :city do
      address.city if address.present?
    end

    attribute :state do
      address.state if address.present?
    end
  end

  # VALIDATIONS
  validates_presence_of :first_name, :last_name, :slug, :about, :work, :education
  validates_uniqueness_of :slug
  validates_uniqueness_of :uid, scope: :provider, if: Proc.new { |u| u.provider.present? }

  after_create :send_welcome_mail

  def send_welcome_mail
    WelcomeMailer.welcome(self).deliver
  end

  def charter_member?

    # key = "charter-czar-#{id}"
    # value = $redis.get(key)
    # return value == 'true' unless value.nil?
    has_sale = Payola::Sale.exists?(owner_id: id, state: 'finished') || false;
    # has_sale = payola_sales.exists?(product_type: 'Product', product_id: [5, 6, 7])
    # $redis.set(key, has_sale)
    # if has_sale
    #   $redis.expire(key, 1.month.to_i)
    # else
    #   $redis.expire(key, 2.minutes.to_i)
    # end
    # has_sale
    return has_sale
  end

  # PROFILE FIELDS
  REQUIRED_PROFILE_FIELDS = [:about]

  def complete_profile?
    REQUIRED_PROFILE_FIELDS.all? { |f| read_attribute(f).present? }
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def forem_name
    full_name
  end

  def following_user_ids
    following.pluck(:following_id)
  end

  def follow(user)
    following_users << user
  end

  def unfollow(user)
    following_users.delete(user)
  end

  def following?(user)
    following_users.include? user
  end

  def reputation_total
    reputation.sum(:amount)
  end

  def czemail_address
    @czemail_address ||= "%s@czardom.com" % slug
  end

  #######################################
  # OMNIAUTH AUTHENTICATION
  #######################################
  def self.from_omniauth(auth)
    where(provider: auth[:provider], uid: auth[:uid]).first_or_create do |user|
      user.update_info_from_facebook(auth)
    end
  end

  def update_info_from_facebook(auth)
    if auth.info.email.present?
      self.email = auth.info.email
    end

    self.password = Devise.friendly_token[0,20]
    self.first_name = auth.info.first_name.present? ? auth.info.first_name : "first_name"
    self.last_name = auth.info.last_name. present? ? auth.info.last_name : "last_name"
    self.remote_image_url = auth.info.image.gsub('http://','https://')
    self.gender = auth.info.gender.present? ? auth.info.gender : 'gender'

    graph = Koala::Facebook::API.new(auth.credentials.token).get_object('me')
    self.about = graph['bio'].present? ? graph['bio'] : "About"
    self.website = graph['website']

    if graph['location'].present?
      location = graph['location']

      if location['name'].present?
        city, state = location['name'].split(',')
        self.build_address({ city: city.try(:strip), state: state.try(:strip), street: '', zip_code: '', country: '' })
      end
    end

    if graph['education'].present?
      school = graph['education'].find { |s| s['type'] == 'College' }
      if school.present?
        self.education = school['school']['name']
      end
    end
    if self.education.blank?
      self.education =  "Education"
    end
    self.work = "Work"
    self
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.first_name = data["first_name"] if user.first_name.blank?
        user.last_name = data["last_name"] if user.last_name.blank?
      end
    end
  end

  def facebook_graph
    @facebook_graph ||= Koala::Facebook::API.new(access_token)
  end

  def facebook_me
    return '' if access_token.blank?
    @facebook_me ||= facebook_graph.get_object('me')
  end

  def slug_url
    Rails.application.routes.url_helpers.user_url(self)
  end

  def total_donated
    sales.sum(:amount) / 100.0
  end

  def address_city
    address.try(:city)
  end

  def address_state
    address.try(:state)
  end

  def online?
    return false unless self[:last_seen].present?
    last_seen > 20.minutes.ago
  end

  def recommendations_count
    Comment.where(commentable_id: id).count
  end

  def likes_count
    posts = Forem::Post.where(user_id: id)
    topics = Forem::Topic.where(user_id: id)

    votes_for_posts = Vote.where(votable: posts).count
    votes_for_topics = Vote.where(votable: topics).count

    votes_for_posts + votes_for_topics
  end
  
  def posts_count 
     Forem::Post.where(user_id:id, reply_to_id: nil).count
  end

  def comments_count 
     Forem::Post.where(user_id:id).where("reply_to_id IS NOT NULL").count
  end
  
  def total_point

    default_points = charter_member? ? 50 : 25
    default_points + 30 * recommendations_count + 2 * likes_count + 10 * posts_count + 2 * comments_count
  end

  # manual send confirm mation email
  def send_confirmation_notification?
    false
  end

  def active_for_authentication?
    return true if self.admin?
    return true if self.charter_member?
    return self.is_approve == 'Approve'
  end

  def avatar
    {
      small: image_url(:small),
      thumb: image_url(:thumb),
      large: image_url(:large)
    }
  end

  def focus_area_json(options={})
    {
      :focus_areas => self.focus_areas.map(&:id),
      :user_segments => self.user_segments.map(&:id),
      :groups => self.groups.map(&:id),
      :latitude => address.blank? ? "" : "#{address.latitude}",
      :longitude => address.blank? ? "" : "#{address.longitude}"
    }
  end

  def as_json(options={})
    {
      :id => id,
      :email => email ,
      :provider => provider ,
       :uid => uid,
       :first_name => first_name,
       :last_name => last_name,
       :avatar => avatar,
       :gender => gender,
       :facebook_url => facebook_url,
       :education => education,
       :work => work,
       :website => website,
       :about => about,
       :cover_photo => cover_photo.url(:square)  ,
       :admin => admin,
       :forem_admin => forem_admin ,
       :forem_state => forem_state,
       :forem_auto_subscribe =>forem_auto_subscribe,
       :twitter_username => twitter_username,
       :linked_in =>linked_in,
       :google_plus_id => google_plus_id,
       :primary_segment_id => primary_segment_id,
       :secondary_segment_id => secondary_segment_id,
       :phone_number => phone_number,
       :pinterest_username =>pinterest_username,
       :resume => resume.url,
       :auto_follow => auto_follow,
       :social_link_vine => social_link_vine,
       :social_link_youtube=> social_link_youtube ,
       :social_link_tumblr => social_link_tumblr,
       :social_link_custom_facebook_url => social_link_custom_facebook_url,
       :social_link_instagram => social_link_instagram,
       :social_link_whatsapp => social_link_whatsapp,
       :social_link_snapchat => social_link_snapchat,
       :notification_by_email => notification_by_email,
       :company_name => company_name,
       :title => title,
       :event_notification => event_notification,
       :street => address.blank? ? "" : "#{address.street}",
       :street2 => address.blank? ? "" : "#{address.street2}",
       :city => address.blank? ? "" : "#{address.city}",
       :state => address.blank? ? "" : "#{address.state}",
       :zip_code => address.blank? ? "" : "#{address.zip_code}",
       :country => address.blank? ? "" : "#{address.country}",
       :created_at => created_at.to_date,
       :updated_at => updated_at.to_date
    }
  end

  def as_json1(options={})
    {
     :id => id,
     :first_name => first_name,
     :last_name => last_name,
     :image => avatar,
     :education => education,
     :work => work,
     :website => website,
     :about => ActionView::Base.full_sanitizer.sanitize(about),
     :street => address.blank? ? "" : "#{address.street}",
     :street2 => address.blank? ? "" : "#{address.street2}",
     :city => address.blank? ? "" : "#{address.city}",
     :state => address.blank? ? "" : "#{address.state}",
     :zip_code => address.blank? ? "" : "#{address.zip_code}",
     :country => address.blank? ? "" : "#{address.country}",
     :latitude => address.blank? ? "" : "#{address.latitude}",
     :longitude => address.blank? ? "" : "#{address.longitude}"
    }
  end

   def has_current_subscription?
    return true if self.has_complimentary_subscription?
    return true if self.login_stripe_id.present?
    false
  end

  def has_not_current_subscription?
    !has_current_subscription?
  end

  def has_complimentary_subscription?
    # be sure to change scope.complimentary along with this method.
    return true if self.admin?
    return true if self.charter_member?
    return true if self.six_month_free?
    false
  end

  def six_month_free?
    Date.parse("01/05/2018") > Time.now
  end

  def have_subscription?
    subscriptions.any?
  end

  def have_not_paid?
    !subscriptions.last.subscription_id.present?
  end

  def make_payment
    if have_subscription? && have_not_paid?
      subscriptions.last.purchase!
    end
  end

  def current_plan
    if have_subscription?
      SignupStripePlan.find_by(
        plan_id: subscriptions.last.plan_id
      )
    end
  end

  protected
  # def confirmation_required?
  #   self.state == 'active'
  # end

  private

  def delete_posts
    Post.where(postable: self).destroy_all
    Post.where(author_id: id).destroy_all
  end

  def parameterize_slug
    self.slug = slug.parameterize
  end

  def indexable?
    active? && !email.include?('fb-user-id.com')
  end

end
