module Forem
  class Post < ActiveRecord::Base
    include Workflow
    include Forem::Concerns::NilUser
    include Forem::StateWorkflow
    acts_as_votable

    # Used in the moderation tools partial
    attr_accessor :moderation_option, :post_from
    # mount_base64_uploader :media, ImageUploader

    belongs_to :topic
    belongs_to :forem_user, :class_name => Forem.user_class.to_s, :foreign_key => :user_id
    belongs_to :reply_to, :class_name => "Post"

    has_many :replies, :class_name  => "Post",
                       :foreign_key => "reply_to_id",
                       :dependent   => :nullify
    has_many :tagged_users
    has_many :users, through: :tagged_users

    validates :text, :presence => true

    delegate :forum, :to => :topic

    after_create :set_topic_last_post_at
    after_create :subscribe_replier, :if => :user_auto_subscribe?
    after_create :skip_pending_review
    after_commit :send_notification_reply, on: :create

    acts_as_likeable
    class << self
      def approved
        where(:state => "approved")
      end

      def approved_or_pending_review_for(user)
        if user
          state_column = "#{Post.table_name}.state"
          where("#{state_column} = 'approved' OR
            (#{state_column} = 'pending_review' AND #{Post.table_name}.user_id = :user_id)",
            user_id: user.id)
        else
          approved
        end
      end

      def by_created_at
        order :created_at
      end

      def pending_review
        where :state => 'pending_review'
      end

      def spam
        where :state => 'spam'
      end

      def visible
        joins(:topic).where(:forem_topics => { :hidden => false })
      end

      def topic_not_pending_review
        joins(:topic).where(:forem_topics => { :state => 'approved'})
      end

      def moderate!(posts)
        posts.each do |post_id, moderation|
          # We use find_by_id here just in case a post has been deleted.
          post = Post.find_by_id(post_id)
          post.send("#{moderation[:moderation_option]}!") if post
        end
      end
    end

    def user_auto_subscribe?
      user && user.respond_to?(:forem_auto_subscribe) && user.forem_auto_subscribe?
      true
    end

    def owner_or_admin?(other_user)
      user == other_user || other_user.forem_admin?
    end

    def reply_url_new
      "/board/#{self.topic.forum.slug}/topics/#{self.topic.slug}/posts/new?reply_to_id=#{id}"
    end

    def reply_url
      "/board/#{self.topic.forum.slug}/topics/#{self.topic.slug}/posts?reply_to_id=#{id}"
    end

    def master_post
      return nil unless self.reply_to.present?
      post = get_master_post(self)
      Dto::Board::ThreadPost.new(post)
    end

    def as_json_revised(options={})
      {
      "id": id,
      "topic_id" => topic.id,
      "forum_name" => topic.forum.name,
      "description": text,
      "user_id": user_id,
      "created_at": created_at,
      "updated_at": updated_at,
      "state": state,
      # "video": video,
      # "image": image,
      "media": media,
      "username": self.user.full_name,
      "usertitle": self.user.title,
      "comments_count": self.replies.count,
      "avatar": self.user.avatar,
      "group_id" => ApplicationController.helpers.get_group(self.topic.forum.id),
      }
    end

    def as_comment_json_revised(options={})
      {
      "id": id,
      "topic_id" => reply_to_id,
      "forum_name" => topic.forum.name,
      "description": text,
      "user_id": user_id,
      "created_at": created_at,
      "updated_at": updated_at,
      "state": state,
      "media": media,
      "username": self.user.full_name,
      "usertitle": self.user.title,
      "comments_count": self.replies.count,
      "avatar": self.user.avatar,
      "group_id" => ApplicationController.helpers.get_group(self.topic.forum.id),
      }
    end

    protected

    def get_master_post(post)
      post = post.reply_to if post.reply_to
      if post.reply_to.nil?
        return post
      else
        get_master_post(post)
      end
    end

    def send_notification_reply
      # SendNotificationJob.perform_later(NotificationsHelper::ACTION_REPLY, id, user_id) if topic && user
    end

    def subscribe_replier
      if topic && user
        topic.subscribe_user(user.id)
      end
    end

    # Called when a post is approved.
    def approve
      approve_user
      return if notified?
      email_topic_subscribers
    end

    def email_topic_subscribers
      topic.subscriptions.includes(:subscriber).find_each do |subscription|
        subscription.send_notification(id) if subscription.subscriber != user
      end
      update_column(:notified, true)
    end

    def set_topic_last_post_at
      topic.update_column(:last_post_at, created_at)
    end

    def skip_pending_review
      approve! unless user && user.forem_moderate_posts?
    end

    def approve_user
      user.update_column(:forem_state, "approved") if user && user.forem_state != "approved"
    end

    def spam
      user.update_column(:forem_state, "spam") if user
    end

  end
end
