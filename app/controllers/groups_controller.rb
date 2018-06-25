class GroupsController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  def index
    respond_with @groups
  end

  def show
    @topics = Forem::Topic
      .where('forum_id = ?', @group.forum_id)
      .by_most_recent_post
      .approved
      .page(params[:page]).per(10)
    respond_with @group
  end

  def update_group_user_list
    @group = Group.find(params[:group_id])
    @users = @group.users
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
    @users = @users.page(params[:page]).per(10)
    render :layout => false
  end 

  private

  # Kaminari defaults page_method_name to :page, will_paginate always uses
  # :page

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
    users.each do |user|
      a1 = Set.new user.user_segments.map(&:id)
      a2 = Set.new segments.map(&:to_i)
      if a2.subset?(a1)
        users_array << user.id
      end
    end
    users.where(id: users_array)
  end
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

end
