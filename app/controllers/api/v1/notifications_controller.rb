class Api::V1::NotificationsController  < Api::V1::BaseController
  
  def index
    # respond_with @events
    if @notifications.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Notifications",
                      :data => { :notification => @notifications.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Notifications",
                      :data => { :notification => "No notifications..." } }
    end
  end

  def all_notifications
    @notifications = current_user.notifications
    if @notifications.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Notifications",
                      :data => { :notification => @notifications.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "Notifications",
                      :data => { :notification => "No notifications..." } }
    end
  end
end