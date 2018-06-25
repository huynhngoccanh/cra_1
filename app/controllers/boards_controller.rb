class BoardsController < ApplicationController
  before_action :authenticate_user!, except: [:fetch_facebook_comments]
  before_action :check_confirmable, only: [:feed]
  before_action :get_follwers, only: [:feed,:board]

  def feed
    # .where('forum_id <> (select id from forem_forums where slug = ?)', 'facebook')
    @post = Forem::Post.new
    load_topics_for_home
    @sliders = Slide.includes(:root_article).order(:position).last(10)
  end

  def board
    @post = Forem::Post.new
    load_topics_for_home
    @sliders = Slide.includes(:root_article).order(:position).last(10)
    render :feed
  end

  def following
    @topics = Forem::Topic
      .by_most_recent_post
      .approved
      .where(id: Forem::Subscription.where(subscriber_id: (current_user.following_user_ids | [current_user.id])).pluck(:topic_id))
      .page(params[:page]).per(30)

      render :feed
  end
  def root_article
    @root_article = RootArticle.find(params[:id])
    @slide = @root_article.slide
    @urls = [];
    @video_url = nil;
    unless @root_article.media.nil? or @root_article.media == ""
      
      url_obj = JSON(@root_article.media)
    
        url_obj.each do |index, data|
     
        if index != "5" 
           @urls.push(data["url"]);
        else 
          @video_url = data["url"];
        end
    
      end
    end

  end

  def fetch_facebook_comments
    
    topic = Forem::Topic.find(params[:topic_id])
   # comment_ids = topic.posts.all.map(&:facebook_post_id)
    comment_ids = topic.posts.pluck(:facebook_post_id).compact
    new_posts = []
    if comment_ids.length == 0 then
    else

      comment_filtered_ids = [];
      post_id = nil;
      comment_ids.each {
        |comment| if comment.include? "_" then 
                    post_id = comment.split('_')[1] 
                  else
                    comment_filtered_ids.push(comment)
                  end
      }
      
      new_comments = Services::NewCommentsForFacebookPost.new_comments(post_id, comment_filtered_ids)
    
      users = User.where(provider: 'facebook', uid: new_comments.map { |c| c['from']['id'] }).group_by(&:uid)
      
      new_comments.each do |raw_comment|
        comment = Facebook::Comment.new(raw_comment)
  
        if user = users.fetch(comment.from_id, false)
          user = user.first
        elsif user = User.find_by(email: "#{comment.from_id}@fb-user-id.com")
          users[comment.from_id] = user
        else
          user = Services::CreateUserFromFacebookComment.new(comment.from).create_user
          users[comment.from_id] = user
        end
  
        new_posts << Forem::Post.create({
          topic: topic,
          user: user,
          text: comment.message,
          created_at: comment.created_at,
          facebook_post_id: comment.id,
          notified: true
        })
      end
    end
    render json: new_posts.map { |p| Dto::Board::ThreadPost.new(p) }, each_serializer: false, serializer: false
  end
 
  def create
    fb_post = {}

    # 2. create facebook post if asked
    begin
      if params[:post_to_facebook].present?
        fb_post = current_user.facebook_graph.put_wall_post("#{params[:subject]}\n#{params[:body]}", {}, ENV['FACEBOOK_GROUP_ID'])
      end
    rescue
      flash[:alert] = "Could not share post to facebook. Make sure you allow us to post to your friends or publicly. You can do this in Facebook app settings."
    end
    # Remove new lines and replace with a space
    topic_title = params[:body].gsub( /\n/m, " " )
    topic_title = topic_title[0,250]
    forum = Forem::Forum.find_by_name(params[:location])
    topic = forum.topics.create({
      user: current_user,
      subject: topic_title,
      slug: Forem::Topic.maximum(:id).next.to_s + "-" + topic_title.parameterize,
      posts_attributes: [{
        user: current_user,
        text: params[:body],
        media: params[:media],
        facebook_post_id: nil
        }]
    })
  
    if params[:tagged_users]
      params[:tagged_users].each do |tagged_user|
        topic.posts.first.tagged_users.build(user_id: tagged_user).save
      end
    end
    group = Group.find_by_forum_id(topic.forum_id)
    params[:tagged_users].to_a.collect{|tagged_user| Notification.create(sender_id: current_user.id,sender_type: "User",receiver_id: tagged_user.to_i,receiver_type: "User",notifiable_id: topic.id, notifiable_type: "Forem::Topic", action: "post",attached_object_id: group.id, attached_object_type: "Group")}
    
    # topic.send_notifications(params[:tagged_users])
    if params[:back_to_board] 
      redirect_to board_path
    else
      redirect_to forem.forum_topic_path(forum, topic)
    end
  end

  # Kaminari defaults page_method_name to :page, will_paginate always uses
  # :page
  def pagination_method
    Kaminari.config.page_method_name
  end
  # Kaminari defaults param_name to :page, will_paginate always uses :page
  def pagination_param
    Kaminari.config.param_name
  end
  helper_method :pagination_param

  def forem_admin_or_moderator?(forum)
    false
  end
  helper_method :forem_admin_or_moderator?

  private

  def get_follwers
    @followers = User.where(id: current_user.followers.pluck(:user_id))
  end

  def load_topics_for_home
    @topics = Forem::Topic
      .by_most_recent_post
      .approved
      .includes(:forem_user,:forum)
      .page(params[:page]).per(10)
      
      # @topics = Forem::Topic
      #   .where(:forum_id => 28)
      #   .by_most_recent_post
      #   .approved
      #   .page(params[:page]).per(30)
  end

  def find_forum_from_location(location)
    id = case location.downcase
         when 'who reps'
           'pr-contacts'
         when 'events'
           'user-events'
         when 'vendors and venues'
           'vendors-and-venues'
         when 'pr resources'
           'pr-resources'
         end

    Forem::Forum.find(id)
  end
end
