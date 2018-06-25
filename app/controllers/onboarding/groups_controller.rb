class Onboarding::GroupsController < OnboardingController
  skip_before_action :onboard_override
  load_resource class_name: 'Group'

  respond_to :html, :json

  def index
    # if current_user.email_confirmed == true
      respond_with @groups
    # else
    #   sign_out current_user
    #   flash[:alert] = "Your account not yet approved by admin"
    #   redirect_to root_path
    # end
  end

  def join
    current_user.like(@group)
    current_user.groups << @group
    @group.add_user(current_user)
    @group.save
    render json: @group
  end

  def leave
    current_user.unlike(@group)
    current_user.groups.delete(@group)
    @group.remove_user(current_user)
    render json: @group
  end

end
