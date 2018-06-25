class Api::V1::ResetPasswordsController  < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create
    user = User.where(user_params).first
    if user.present?
      user.send_reset_password_instructions
      render :status => 200,
           :json => { :success => true,
                      :info => "Please check your email address, a password reset link has been sent to your email address",
                    }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Invalid email address",
                      :data => {  } }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

end