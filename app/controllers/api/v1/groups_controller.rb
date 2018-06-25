class Api::V1::GroupsController  < Api::V1::BaseController

	skip_before_action :verify_authenticity_token, only: [:update_groups,:add_groups,:group_users]

	def all_groups
		groups = Group.all
		if groups.present?
		 	
			
			render :status => 200,
           :json => { :success => true,
                      :info => "All Groups",
                      :data => { :all_groups => groups.as_json } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "No Groups..." }
		end
	end

	def index
		groups = current_user.groups
		if groups.present?
			render :status => 200,
           :json => { :success => true,
                      :info => "Groups",
                      :data => { :user_groups => groups } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "No Groups..." }
		end
	end

	def group_users
		group = Group.find(params[:group][:id])
		if group.present?
			group_users = []
			users = group.users
			limited_users = users.limit(params[:group][:limit]).offset(validate_start_value(params[:group][:start]))
			if limited_users.present?
				limited_users.each do |group_user|
					followed = current_user.try :following?, group_user
					group_users << group_user.as_json1.merge(:followed => followed)
				end
				render :status => 200,
           :json => { :success => true,
                      :info => "Groups users",
                      :data => { :total => users.count, :users => group_users } }
      else
      	render :status => 400,
           :json => { :success => false,
                      :info => "Users not found for this group..." }
      end
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "Group not found..." }
		end
	end

	def update_groups
		GroupUser.where(:user_id => current_user).delete_all
		if params[:group][:groups].present?
			params[:group][:groups].each do |group_id|
				group = current_user.group_users.build(:group_id => group_id.last).save
			end
			render :status => 200,
           :json => { :success => true,
                      :info => "Groups",
                      :data => { :updated_user_groups => current_user.groups } }
		else
			render :status => 400,
           :json => { :success => true,
                      :info => "No group selected..." }
		end
	end

	def add_groups
		if params[:group][:groups].present?
			params[:group][:groups].each do |group_id|
				unless  current_user.group_users.where(:group_id => group_id.last).present?
					group = current_user.group_users.build(:group_id => group_id.last).save
				end
			end
			render :status => 200,
           :json => { :success => true,
                      :info => "Groups",
                      :data => { :updated_user_groups => current_user.groups } }
		else
			render :status => 400,
           :json => { :success => true,
                      :info => "No group added..." }
		end
	end
end