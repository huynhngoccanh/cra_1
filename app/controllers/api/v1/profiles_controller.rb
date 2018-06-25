class Api::V1::ProfilesController  < Api::V1::BaseController
	skip_before_action :verify_authenticity_token, only: [:users_by_name, :board_group, :update_expertise]
  
	def show
	end

	def personal_details
    posts = Forem::Post.where(:user_id => current_user.id).count
		render :status => 200,
           :json => { :success => true,
                      :info => "Profile",
                      :data => { :personal_details => current_user.as_json.merge(:followers => current_user.followers.count, :post => posts )} }
	end

	def expertise
		render :status => 200,
           :json => { :success => true,
                      :info => "Profile",
                      :data => { :core_skills_and_expertise => current_user.user_segments.map(&:id).as_json, :additional_areas_of_focus => current_user.focus_areas.map(&:id).as_json } }
	end

	def additional_info
		render :status => 200,
           :json => { :success => true,
                      :info => "Profile",
                      :data => { :additional_info => current_user.as_json.merge(:street => current_user.address.street, :street2 => current_user.address.street2, :city => current_user.address.city, :state => current_user.address.state, :zip_code => current_user.address.zip_code, :country => current_user.address.country  ) } }
	end

	def update_expertise
		resource = current_user
		if params[:profile][:focus_area_ids].present?
      resource.user_focus_areas.delete_all
      params[:profile][:focus_area_ids].each do |focus_area|
        resource.user_focus_areas.build(:focus_area_id => focus_area).save
      end
    end
    if params[:profile][:user_segment_ids].present? 
      resource.user_segmentations.delete_all
      params[:profile][:user_segment_ids].each do |user_segment|
        resource.user_segmentations.build(:user_segment_id => user_segment).save
      end
    end
    render :status => 200,
           :json => { :success => true,
                      :info => "Profile",
                      :data => { :core_skills_and_expertise => resource.user_segments.map(&:name).as_json, :additional_areas_of_focus => resource.focus_areas.map(&:name).as_json } }
	end

	def users_by_name
		users = User.where("first_name LIKE ? or last_name LIKE ?", "#{params[:user][:name]}","#{params[:user][:name]}" )
		if users.present?
			render :status => 200,
           :json => { :success => true,
                      :info => "Users",
                      :data => { :users => users } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "No Users..." }
		end
	end

	def board_group
		group = Group.find(params[:board][:group_id])
		if group.present?
			forum = group.forum
			if forum.present?
				topics = forum.topics.order('id DESC').limit(params[:board][:limit].to_i).offset(validate_start_value(params[:board][:start].to_i))
				if topics.present?
					render :status => 200,
		           :json => { :success => true,
		                      :info => "Board topics",
		                      :data => { :board_topics => json_topics(topics, params[:board][:group_id])} }
				else
					render :status => 400,
		           :json => { :success => false,
		                      :info => "No Board Topic..." }
		    end
			else
				render :status => 400,
	             :json => { :success => false,
	                        :info => "Sorry Forum not found..." }
			end
		else
			render :status => 400,
	             :json => { :success => false,
	                        :info => "Sorry Group not found..." }
	  end
	end

	def main_board
		topics = Forem::Topic.by_most_recent_post.includes(:forem_user,:forum).approved.limit(50)
    if topics.present?
    	final_topics = []
    	topics.each do |topic|
    		 group = Group.where(forum_id: topic.forum_id).first
    		 if group == nil
    		 		group_id = -1
    		 else 
    		 	group_id = group.id 
    		 end
    		
    	 	final_topics << topic.as_json.merge(:group_id => group_id, :comments => "#{topic.posts.includes(:replies).count - 1}", :media => topic.posts.first.media)
    	end
			render :status => 200,
           :json => { :success => true,
                      :info => "Main Czardom Board",
                      :data => { :board_topics => final_topics } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "No Board Topic..." }
    end
	end

	def friend_profile
		user = User.find(params[:friend_id])
		followers = User.where(id: user.followers.pluck(:user_id))
		followed_users = current_user.following_users.map(&:id)
		value = followed_users.include? user.id
		following = value ? "Yes" : "No"
		if user.present?
			render :status => 200,
           :json => { :success => true,
                      :info => "Friend Profile",
                      :data => { :profile => user.as_json.merge(:street => user.address.street, :street2 => user.address.street2, :city => user.address.city, :state => user.address.state, :zip_code => user.address.zip_code, :country => user.address.country, :following => following, :posts => user.forem_topics.count, :followers => followers.count, :groups => user.groups ) } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "User not found..." }
    end
	end

	private
	def current_user
      if params[:authentication_token]
        @current_user = User.find_by_authentication_token params[:authentication_token]
      end
    end
    
    def json_topics(topics, group_id)
    	final_topics = []
    	topics.each do |topic|
	    	if group_id == nil
				 group = Group.where(forum_id: topic.forum_id).first
				 if group == nil
				 		group_id = -1
				 else 
				 	group_id = group.id 
				 end
		    end
		    	final_topics << topic.as_json.merge(:group_id => group_id, :comments => "#{topic.posts.includes(:replies).count - 1}", :media => topic.posts.first.media)
		end
        return final_topics
   end
end