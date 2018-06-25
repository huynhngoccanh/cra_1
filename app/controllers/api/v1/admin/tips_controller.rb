class Api::V1::Admin::TipsController  < Api::V1::BaseController
	before_action :verify_admin
	skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]

	def index
		tips = Tip.all
		render :status => 200,
           :json => { :success => true,
                      :info => "Tips",
                      :data => { :tips => tips } }
	end

	def create
		tip = Tip.new(:content => params[:tip][:content])
		if tip.save
			render :status => 200,
           :json => { :success => true,
                      :info => "Tips",
                      :data => { :tip => tip } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "Tip not created..." }
		end
	end

	def update
		tip = Tip.find(params[:id])
		if tip.present?
			if tip.update(:content => params[:tip][:content])
				render :status => 200,
	           :json => { :success => true,
	                      :info => "Tips",
	                      :data => { :tip => tip } }
			else
				render :status => 400,
	           :json => { :success => false,
	                      :info => "Tip not updated..." }
			end
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "Tip not found..." }
    end
	end

	def show
		tip = Tip.find(params[:id])
		if tip.present?
			render :status => 200,
           :json => { :success => true,
                      :info => "Tip",
                      :data => { :tip => tip } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "Tip not found..." }
		end
	end

	def destroy
		tip = Tip.find(params[:id])
		if tip.present?
			tip.delete
			render :status => 200,
           :json => { :success => true,
                      :info => "Tip deleted successfully...",
                      :data => { :tip => tip } }
		else
			render :status => 400,
           :json => { :success => false,
                      :info => "Tip not found..." }
    end
	end

	private
	def verify_admin
		user = User.find_by(authentication_token: params[:authentication_token])
		if user.present?
			unless user.admin?
				render :status => 401,
             :json => { :success => false,
                        :info => "Not Authorized..." }
			end
		end
	end
end