class UsersController < ApplicationController
  skip_before_action :onboard_override, only: [:edit, :update, :subscriptions, :payment]
  skip_before_action :check_subscription, only: [:edit, :update, :subscriptions, :payment]
  load_and_authorize_resource except: [:new, :create, :confirm_account,:payment, :billing, :my_invoice,:make_payment]
  skip_before_action :verify_authenticity_token, only: [:create, :update]
  before_action :check_confirmable, only: [:show, :edit]
  protect_from_forgery :except => [:billing, :payment]
  include ApplicationHelper

  respond_to :html, :json
  require 'httparty'

  require "stripe"
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  Stripe.api_version = "2018-01-23"

  def new
    @plan = SignupStripePlan.first

    if session['devise.facebook_data'].blank?
      @user = User.new
      @user.email = params[:email]
      @user.first_name = params[:first_name]
      @user.last_name = params[:last_name]
    else
      @user = User.from_omniauth(Hashie::Mash.new(session['devise.facebook_data']))
    end

    @user.build_address if @user.address.blank?

    respond_with @user
  end

  def create
    @user = User.new(user_params)

    unless session['devise.facebook_data'].blank?
      @user.password = @user.password_confirmation = Devise.friendly_token[0,20]
      @user.provider = 'facebook'
      @user.uid = session["devise.facebook_data"]['uid']
      @user.skip_confirmation!
    end

    @user.state = 'onboarding_groups'

    if @user.save
      @user.following_users << User.where(auto_follow: true)
      process_payment
      bypass_sign_in(@user)
      redirect_to thankyou_path
    else
      @plan = SignupStripePlan.first
      render 'new'
    end
  end

  def show
    @user = @user.decorate
    @recommend_user = User.find(params[:id])
    @new_comment    = Comment.build_from(@recommend_user, current_user.id, "")
    @comments = Comment.where(commentable_id: @user.id)
    # @events = Event.where(:user_id => current_user)
    # @event_images = @events.includes(:event_images)
    @event_images = @user.profile_images.order("id DESC")
    @event_videos = @user.profile_videos.order("id DESC")
    respond_with @user
  end

  def edit
    @user = current_user if @user.blank?
    @user.build_address if @user.address.blank?
    respond_with @user
  end

  def edit_clients
    @user = current_user if @user.blank?
    @user.clients.build
    respond_with @user
  end

  def edit_groups
    @user = current_user if @user.blank?
    respond_with @user
  end

  def edit_password
    @user = current_user if @user.blank?
    respond_with @user
  end

  def update
    if @user.update_attributes(user_params)
      respond_with @user
    else
      action = params[:user_action]
      if action == 'edit_password'
        render :edit_password
      else
        render :edit
      end
    end
  end

  def image
    redirect_to @user.image_url(:small)
    # image = open(@user.image_url(:small))
    # send_data image.read, type: image.content_type, disposition: :inline, x_sendfile: true
  end

  def blurbs
    users = User.where(id: params[:ids])
    response = {}

    users.each do |user|
      response[user.id] = {
        full_name: user.full_name,
        slug: user.slug_url,
        avatar: user.image_url(:small),
        about: user.about
      }
    end

    render json: response
  end

  def follow
    @following_user = User.find(params[:user_id])

    if current_user.following?(@following_user)
      current_user.unfollow @following_user
    else
      current_user.follow @following_user
    end
  end

  def followed
    @following_users = current_user.following_users
    unless params[:search].blank?
      @following_users = search_user(@following_users, "%#{params[:search]}%")
    end
    @following_users = @following_users.page(params[:page]).per(10)
  end

  def followers
    @followers = User.where(id: current_user.followers.pluck(:user_id))
    unless params[:search].blank?
      @followers = search_user(@followers, "%#{params[:search]}%")
    end
    @followers = @followers.page(params[:page]).per(10)
  end

  def posts
    @posts = Forem::Post.where(user_id: current_user.id).page(params[:page]).per(10)
  end

  def all_czars
    @user_segments = UserSegment.all
    @users = User.page(params[:page]).per(10)
  end

  def update_czar_list
    @users = User.all
    unless params[:search].blank?
      @users = search_user(@users, "%#{params[:search]}%")
    end
    unless params[:city].blank?
      @users = search_city_filter(@users, "%#{params[:city]}%")
    end
    unless params[:client_name].blank?
      @users = search_client_filter(@users, "%#{params[:client_name]}%")
    end
    unless params[:agency_name].blank?
      @users = search_agency_filter(@users, "%#{params[:agency_name]}%")
    end
    unless params[:segments].blank?
      @users = search_segment_filter(@users, params[:segments])
    end
    if(params[:page] )
       @users = @users.page(params[:page]).per(10)
    else
      @users = Kaminari.paginate_array(@users).page(params[:page]).per(10)
    end

    @user_segments = UserSegment.all
    respond_to do |format|

         format.js { render 'update_czar_list.js.erb' }
         format.html {render :all_czars }
    end
    #render :layout => false
    #render :json => @users
    # respond_with @users do |format|
    #   format.json { render :layout => false, :json => @users}
    # end

  end

  def verify_url
    if params[:url].present?
      # OEmbed::Providers.register_all
      # resource = OEmbed::Providers.get(params[:url])
      # response = HTTParty.get("https://www.youtube.com/oembed?format=json&url=#{params[:url]}")
      @video = VideoInfo.new("#{params[:url]}")
    else
      @video = nil
    end
    render :layout => false
  end

  def update_event_image
    event_image = EventImage.find(params[:event_image_id])
    if params[:event_image][:image].present?
      event_image.update_attributes(:image => params[:event_image][:image])
      redirect_to main_app.user_path(current_user), notice: "Image updated successfully..."
    else
      redirect_to main_app.user_path(current_user), notice: "Please upload image to update..."
    end
  end

  def delete_event_image
    event_image = EventImage.find(params[:event_image_id])
    event_image.destroy
    redirect_to main_app.user_path(current_user), notice: "Image deleted successfully..."
  end

  def update_event_video
    event_video = EventVideo.find(params[:event_video_id])
    if params[:event_video][:video_url].present?
      if event_video.update_attributes(:video_url => params[:event_video][:video_url])
        redirect_to main_app.user_path(current_user), notice: "Video updated successfully..."
      else
        redirect_to main_app.user_path(current_user), notice: "Please enter valid youtube video url to update..."
      end
    else
      redirect_to main_app.user_path(current_user), notice: "Please enter valid youtube video url to update..."
    end
  end

  def delete_event_video
    event_video = EventVideo.find(params[:event_video_id])
    event_video.destroy
    redirect_to main_app.user_path(current_user), notice: "Video deleted successfully..."
  end

  def confirm_account
    @user = User.find_by_account_confirm_token(params[:token])
    @user.update_attributes(confirmed_at: DateTime.now )
    @plan = SignupStripePlan.first
    @api_key = ENV['STRIPE_PUBLISHABLE_KEY']
    render 'account_activated'
    if @user.login_stripe_id.present?
      render 'account_activated'
    else
      render 'make_payment'
    end
  end
  

     
  def make_payment
    @api_key = ENV['STRIPE_PUBLISHABLE_KEY']
  end

  def subscriptions
    @user = current_user
    @plan = SignupStripePlan.first
    @api_key = ENV['STRIPE_PUBLISHABLE_KEY']
    render 'make_payment'
  end


  def payment
    @user = current_user
    process_payment
    redirect_to root_url
  end

  def billing
    begin
      event = JSON.parse(request.body.read)
      event_type =  event["type"]
      if event_type == "invoice.payment_succeeded"

        invoice_id = event["data"]["object"]["id"]
        currency = event["data"]["object"]["currency"]
        amount = event["data"]["object"]["lines"]["data"][0]["amount"]
        start_date = event["data"]["object"]["lines"]["data"][0]["period"]["start"]
        end_date = event["data"]["object"]["lines"]["data"][0]["period"]["end"]
        customer_id = event["data"]["object"]["customer"]
        paid = event["data"]["object"]["paid"]
        s_date = Time.at(start_date).to_datetime.strftime("%d-%m-%Y")
        e_date = Time.at(end_date).to_datetime.strftime("%d-%m-%Y")

        Invoice.create(
          invoice_id: invoice_id,
          currency: currency,
          amount: amount,
          start_date: s_date,
          end_date: e_date,
          customer_id: customer_id,
          pay_status: paid
        )
      end
    rescue Exception => ex
      render :json => {:status => 422, :error => "Webhook call failed"}
      return
    end
    render :json => {:status => 200}
  end


  def my_invoice
    if current_user.login_stripe_id.present?
      @cards = Stripe::Customer.retrieve(current_user.login_stripe_id).sources.all(:object => "card").data
      @invoices = Invoice.where("customer_id = ?", current_user.login_stripe_id)
    else
      @cards = []
      @invoices = []
    end
  end

  private

  def search_user(users, text_search)
    text = text_search.to_s.downcase
    users.where("lower(first_name) || ' ' || lower(last_name) like :s", :s => "%#{text}")
  end

  def search_city_filter(users, text_search)
    text = text_search.to_s.downcase
    address_filter = Address.where("lower(city) like :s", :s => "%#{text}")
    users = users.joins(:address).merge(address_filter)
  end

  def search_client_filter(users, text_search)
    text = text_search.to_s.downcase
    client_filter = UserClient.where("lower(name) like :s", :s => "%#{text}")
    users = users.joins(:clients).merge(client_filter)
  end

  def search_agency_filter(users, text_search)
    text = text_search.to_s.downcase
    users.where("lower(work) like :s", :s => "%#{text}")
  end

  def search_segment_filter(users,segments)
    users_array = []
    a2 = Set.new segments.map(&:to_i)
    users.each do |user|
      a1 = Set.new user.user_segments.map(&:id)
      if a2.subset?(a1)
        users_array << user
      end
    end
    return users_array
    # users.where(id: users_array)
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation, :phone_number, :about, :resume, :slug,
      :company_name, :title,
      :notification_by_email,
      :event_notification,
      :image, :cover_photo,
      :education, :work, :facebook_url, :website,
      :image_cache, :cover_photo_cache,
      :twitter_username, :linked_in, :google_plus_id, :pinterest_username,
      :social_link_custom_facebook_url, :social_link_vine, :social_link_youtube, :social_link_tumblr,
      :social_link_instagram, :social_link_snapchat, :social_link_whatsapp,
      :primary_segment_id,
      :user_segment_ids => [],
      :focus_area_ids => [],
      :group_ids => [],
      :clients_attributes => [:id, :name, :website, :image, :bio, :position, :_destroy],
      :address_attributes => [:street, :street2, :city, :state, :zip_code, :country, :id]
    )
  end
  def recommend
  end

  def process_payment
    plan = Stripe::Plan.retrieve(SignupStripePlan.find(params[:user_plan_id]).plan_id)

    customer = unless @user.stripe_id.present?
      Stripe::Customer.create(
        :description => "Activate Account",
        :email => @user.email,
        :source  => params[:stripeToken]
      )
    else
      Stripe::Customer.retrieve(@user.stripe_id)
    end

    @user.update_attributes(
      stripe_id: customer.id,
      login_stripe_id: customer.id,
      account_confirm_token: nil,
      email_confirmed: true,
      login_stripe_card_holder: params[:card_holder_name],
      login_stripe_postal_code: '',
      confirmed_at: DateTime.now
    )

    subscription = @user.subscriptions.create(
      plan_id: plan.id
    )

    flash[:message] = "Payment successfully!"
  rescue Stripe::CardError => e
    flash[:danger] = e.message
  end
end
