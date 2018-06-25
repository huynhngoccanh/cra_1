class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  include ApplicationHelper
  respond_to :json
  before_action :authenticate_user!
  before_action :verify_token

  before_filter :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = %w{Origin Accept Content-Type X-Requested-With auth_token X-CSRF-Token}.join(',')
    headers['Access-Control-Max-Age'] = "1728000"
  end


  private
    def verify_token
      user = User.find_by(authentication_token: params[:authentication_token])
      if user.nil?
        render :status => 401,
             :json => { :success => false,
                        :info => "Authentication Token Not Present..." }
      else
        if user != current_user
          render :status => 401,
             :json => { :success => false,
                        :info => "Authentication Token Not matched with logged user..." }
        end
      end
    end
end
