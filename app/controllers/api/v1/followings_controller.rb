class Api::V1::FollowingsController  < Api::V1::BaseController
	def index
		@followers = User.where(id: current_user.followers.pluck(:id))
		followed_users = current_user.following_users.map(&:id)
        if @followers.present?
          follower_users = []
          @followers.each do |follower|
            value = followed_users.include? follower.id
            following = value ? "Yes" : "No"
            follower_users << follower.as_json.merge(:following => following) 
          end
        	render :status => 200,
               :json => { :success => true,
                          :info => "Followers",
                          :data => { :followers => follower_users } }
        else
        	render :status => 400,
               :json => { :success => false,
                          :info => "No Followers..." }
        end
	end
	
	def followed
		@followed_users = current_user.following_users
		if @followed_users.present?
    	render :status => 200,
           :json => { :success => true,
                      :info => "Followed users",
                      :data => { :followed => @followed_users.as_json } }
    else
    	render :status => 400,
           :json => { :success => false,
                      :info => "No followed users..." }
    end
	end

	def near_by_peoples
		users = []
		addresses = Address.near([current_user.address.latitude,current_user.address.longitude],50)
		unless addresses.nil?
			addresses.each do |address|
				users << address.addressable.as_json.merge(latitude: address.latitude, longitude: address.longitude) if address.addressable.present? && address.addressable != current_user
			end
			render :status => 200,
           :json => { :success => true,
                      :info => "Near by People",
                      :data => { :my_location => current_user.address.as_json.merge(latitude: current_user.address.latitude, longitude: current_user.address.longitude),:peoples => users.reject(&:nil?) } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "No near by peoples..." }
		end
	end
end
