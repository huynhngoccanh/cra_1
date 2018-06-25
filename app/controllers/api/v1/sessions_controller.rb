class Api::V1::SessionsController < Devise::SessionsController
  api :POST, '/users/sign_in', "Sign In"
  param :users, Hash , :description => "User" do 
   param :email, String, "User email", required: true  
   param :password, String, "User Password", required: true
   param :provider, String, "Social Provider"
   param :token, String, "Devise Token", required: false
  end
  description <<-EOS
    == Fetch User Profile
     This API is used to fetch the user profile details.
    === Authentication required
     Authentication token has to be passed as part of the request. It can be passed as parameter(auth_token) or HTTP header(AUTH-TOKEN). 
  EOS
  def create
    # Fetch params
    login = params[:user][:email].downcase if params[:user][:email]
    password = params[:user][:password] if params[:user]
    provider = params[:user][:provider] if params[:provider]    
    
    
    # id = User.find_by(email: login).try(:id) if login.presence

    # Validations
    if request.format != :json
      render status: 200, json: { info: 'The request must be JSON.' }
      return
    end

    if login.nil? or password.nil?
      render status: 400, json: { info: 'The request MUST contain the user email and password.' }
      return
    end

    # Authentication
    user = User.where(["lower(email) = :value", { :value => login }]).first

    if user
      if user.valid_password? password
        user.restore_authentication_token!
        user.authentication_token = Devise.friendly_token
        user.save
        # Note that the data which should be returned depends heavily of the API client needs.
        render status: 200, json: { info: "Login succeed!", :data => { user: user.as_json.merge(user.focus_area_json), :authentication_token => user.authentication_token}, success: true }
      else
        render status: 400, json: { info: 'Invalid email or password.', success: false }
      end
    else
      render status: 400, json: { info: 'Invalid email or password.', success: false }
    end
  end
  api :DELETE, '/users/sign_out', "Sign Out"
  def destroy
    # Fetch params
    user = User.find_by(authentication_token: params[:user][:authentication_token])

    if user.nil?
      render status: 401, json: { message: 'Invalid token.' }
    else
      user.authentication_token = nil
      user.save(:validate=>false)
      sign_out user
      render :status => 200,
           :json => { :success => true,
                      :info => "User Successfully Logged Out",
                      :data => {} }
    end
  end

  def failure
    render :status => 400,
           :json => { :success => false,
                      :info => "Login Failed",
                      :data => {} }
  end

  protected
    def ensure_params_exist
      return unless params[:user].blank?
      render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>200
    end
end