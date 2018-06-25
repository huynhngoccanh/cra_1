class Api::V1::ApiPostsController  < Api::V1::BaseController

  # before_action :find_topic, :except [:index]
  # before_filter :find_post, :only [:show]
  skip_before_action :verify_authenticity_token, only: [:create, :post_rply]

  def index
    posts = Forem::Post.where(:user_id => current_user.id, :reply_to_id => nil)
    if posts.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Posts",
                      :data => { :post => posts } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "No Posts..." }
    end
  end

  def get_topic
    topic = Forem::Topic.find(params[:topic_id])
    if topic.present?
      final_value = []
      comments = topic.posts.where(:reply_to_id => nil)
      comments.each do |comment|
        reply_collection = []
        if comment.replies.present?
          comment.replies.each do |reply|
            reply_on_reply_collection = []
            reply_collection << reply.as_json_revised
            #reply_collection << reply.as_comment_json.merge(:author_name => reply.user.full_name, :author_avatar => reply.user.image.url)
            if reply.replies.present?
              reply.replies.each do |rply_on_rply|
                #reply_collection << rply_on_rply.as_comment_json.merge(:author_name => rply_on_rply.user.full_name, :author_avatar => rply_on_rply.user.image.url)
                reply_collection << rply_on_rply.as_comment_json_revised
              end
            end
            # reply_collection << reply_on_reply_collection unless reply_on_reply_collection.empty?
          end
        end
        unless reply_collection.empty?
          #final_value << comment.as_json_revised.merge(:author_name => comment.user.full_name, :author_avatar => comment.user.image.url,:replies => reply_collection)
          final_value << comment.as_json_revised.merge(:replies => reply_collection)
        else
          #final_value << comment.as_json_revised.merge(:author_name => comment.user.full_name, :author_avatar => comment.user.image.url)
          final_value << comment.as_json_revised
        end
      end
      render :status => 200,
           :json => { :success => true,
                      :info => "Posts",
                      :data => final_value ,
                      :data => { :post_id  => topic.posts.first.id, :topic_id => topic.id,  :comments => final_value }
                    }
                      # :data => { :post  => topic.as_json.merge(:author_name => topic.user.full_name, :author_avatar => topic.user.image.url,:comments => final_value) } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Topic not present..." }
    end
  end

  def show
    @post = Forem::Post.find(params[:id])
    if @post.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Post",
                      :data => { :post => @post.as_json_revised } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "post not present..." }
    end
  end

  def create
    topic_title = params[:post][:body].gsub( /\n/m, " " )
    topic_title = topic_title[0,250]
    forum = Forem::Forum.find(params[:post][:forum_id])
    if forum.present?
      topic = forum.topics.create({
      user: current_user,
      subject: topic_title,
      slug: Forem::Topic.maximum(:id).next + "-" + topic_title.parameterize,
      posts_attributes: [{
        user: current_user,
        text: params[:post][:body],
        media: params[:post][:media],
        facebook_post_id: nil
        }]
      })
    
      if topic.save
        topic_json = []
        topic_json << topic.as_json.merge(:comments_count => 0,:media => params[:post][:media])
        render :status => 200,
             :json => { :success => true,
                        :info => "Posts created",
                        :data => { :post => topic_json }}
                       
      else
        render :status => 400,
             :json => { :success => false,
                        :info => "Sorry Post not created..." }
      end
    else
      render :status => 400,
             :json => { :success => false,
                        :info => "Sorry Forum not found..." }
    end
  end

  def post_rply
    @topic = Forem::Topic.find(params[:post][:topic_id])
    # authorize! :reply, @topic
    if params[:post][:reply_to_id].present?
      @post = @topic.posts.build(user: current_user, text: params[:post][:body], reply_to_id: params[:post][:reply_to_id])
    else
      @post = @topic.posts.build(user: current_user, text: params[:post][:body])
    end
    @post.user = forem_user

    if @post.save
      render :status => 200,
           :json => { :success => true,
                      :info => "Comment created",
                      :data => { :comment => @post.as_json_revised} }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Sorry comment not created..." }
    end
  end

  def subscribe
    @topic = Forem::Topic.find(params[:topic_id])
    @topic.subscribe_user(forem_user.id)
    render :status => 200,
           :json => { :success => true,
                      :info => "subscribed successfully" }
  end

  def unsubscribe
    @topic = Forem::Topic.find(params[:topic_id])
    @topic.unsubscribe_user(forem_user.id)
    render :status => 200,
           :json => { :success => true,
                      :info => "unsubscribed successfully" }
  end

  def follow
    @following_user = User.find(params[:user_id])
    
    if current_user.following?(@following_user)
      current_user.unfollow @following_user
      render :status => 200,
           :json => { :success => true,
                      :info => "unfollowed" }
    else
      current_user.follow @following_user
      render :status => 200,
           :json => { :success => true,
                      :info => "followed" }
    end
  end

  def get_comments
    post = Forem::Post.find(params[:post_id])
    comments = post.replies
    all_comments = []
    if comments.present?
      comments.each do |comment|
        all_comments << comment.as_json_revised.merge(replies: comment.replies.reverse)
      end
      render :status => 200,
         :json => { :success => true,
                    :info => "Comments",
                    :data => { :comments => all_comments } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "No comments..." }
    end
  end

  private

    # def post_params
  #     params.require(:post).permit(:text, :reply_to_id)
  #   end

    # def authorize_reply_for_topic!
  #     authorize! :reply, @topic
  #   end

    # def find_topic
    #   @topic = Forem::Topic.friendly.find params[:topic_id]
    # end

    # def find_post
    #   byebug
  #     @post = Forem::Post.where(:id => params[:id])
  #   end

    # def block_spammers
  #     if forem_user.forem_spammer?
  #       render :status => 200,
  #          :json => { :success => false,
  #                     :info => t('forem.general.flagged_for_spam') + ' ' +
  #                       t('forem.general.cannot_create_post') }
  #     end
  #   end
end