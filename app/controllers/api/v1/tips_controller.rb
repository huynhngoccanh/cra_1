class Api::V1::TipsController  < Api::V1::BaseController
	before_action :verify_admin

	def index
	end

	private
	def verify_admin
		user = User.find_by(authentication_token: params[:authentication_token])
		if user.present?
			unless user.admin?
				render :status => 200,
             :json => { :success => false,
                        :info => "Not Authorized..." }
			end
		end
	end
end