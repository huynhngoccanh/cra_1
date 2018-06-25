class Api::V1::RegistrationsController < Devise::RegistrationsController

  def create
    resource = User.new(user_params)
    puts params
    puts resource
    if resource.save
      if params[:user][:focus_area_ids].present?
        params[:user][:focus_area_ids].each do |focus_area|
          resource.user_focus_areas.build(:focus_area_id => focus_area).save
        end
      end
      if params[:user][:user_segment_ids].present? 
        params[:user][:user_segment_ids].each do |user_segment|
          resource.user_segmentations.build(:user_segment_id => user_segment).save
        end
      end
      sign_in resource
      render :status => 200,
           :json => { :success => true,
                      :info => "Successfully Registered The #{resource.class}",
                      :data => { "#{resource.class.to_s.downcase}"=>resource.as_json,
                                 :authentication_token => resource.authentication_token } }
    else
      render :status => 400,
             :json => { :success => false,
                        :info => resource.errors.full_messages.join(","),
                        :data => {} }
    end
  end

  def update
    resource = current_user
    if resource.update(user_update_params)
      if params[:user][:focus_area_ids].present?
        resource.user_focus_areas.delete_all
        params[:user][:focus_area_ids].each do |focus_area|
          resource.user_focus_areas.build(:focus_area_id => focus_area).save
        end
      end
      if params[:user][:user_segment_ids].present?
        resource.user_segmentations.delete_all 
        params[:user][:user_segment_ids].each do |user_segment|
          resource.user_segmentations.build(:user_segment_id => user_segment).save
        end
      end
      render :status => 200,
           :json => { :success => true,
                      :info => "Successfully Updated",
                      :data => { "#{resource.class.to_s.downcase}"=>resource.as_json.merge(:core_skills_and_expertise => resource.user_segments.map(&:name).as_json, :additional_areas_of_focus => resource.focus_areas.map(&:name).as_json),
                                 :authentication_token => resource.authentication_token } }
    else
      render :status => 400,
             :json => { :success => false,
                        :info => resource.errors.full_messages.join(","),
                        :data => {} }
    end
  end
  def get_all_focus_areas
    focus_areas = FocusArea.all
    if focus_areas.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Additional Areas of Focus",
                      :data => { :focus_areas => focus_areas } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "No additional area of focus..." }
    end
  end

  def get_all_core_skills
    user_segments = UserSegment.all
    if user_segments.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Core Skills and Expertise",
                      :data => { :core_skills_and_expertise => user_segments } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "No core skills and expertise..." }
    end
  end

  private
    def user_params
      # byebug
      # params[:user][:user_segment_ids] = params[:user][:user_segment_ids].gsub("[", "").gsub("]", "").split(",") unless params[:user][:user_segment_ids].blank?
      # params[:user][:focus_area_ids] = params[:user][:focus_area_ids].gsub("[", "").gsub("]", "").split(",") unless params[:user][:focus_area_ids].blank?
      params.require(:user).permit(:email , :password, :password_confirmation , :provider ,
       :uid , :first_name , :last_name, :image, :gender, :facebook_url , :education , :work ,
       :website , :about , :cover_photo , :admin , :forem_admin , :forem_state ,
       :forem_auto_subscribe , :twitter_username , :linked_in , :google_plus_id , :primary_segment_id ,
       :secondary_segment_id , :phone_number , :pinterest_username , :resume , :state , :auto_follow ,
       :social_link_vine , :social_link_youtube , :social_link_tumblr , :social_link_custom_facebook_url ,
       :social_link_instagram , :social_link_whatsapp , :social_link_snapchat , :roles_mask ,
       :notification_by_email , :company_name , :title , :event_notification, 
       :focus_area_ids=>[], :user_segment_ids=>[],
       :address_attributes => [:street, :street2, :city, :state, :zip_code, :country]
       )
    end

    def user_update_params
      params.require(:user).permit( :provider ,
       :uid , :first_name , :last_name , :image, :gender, :facebook_url , :education , :work ,
       :website , :about , :cover_photo , :forem_admin , :forem_state ,
       :forem_auto_subscribe , :twitter_username , :linked_in , :google_plus_id , :primary_segment_id ,
       :secondary_segment_id , :phone_number , :pinterest_username , :resume , :state , :auto_follow ,
       :social_link_vine , :social_link_youtube , :social_link_tumblr , :social_link_custom_facebook_url ,
       :social_link_instagram , :social_link_whatsapp , :social_link_snapchat , :roles_mask ,
       :notification_by_email , :company_name , :title , :event_notification, :focus_area_ids=>[], :user_segment_ids=>[],
       :address_attributes => [:street, :street2, :city, :state, :zip_code, :country]
       )
    end

    def current_user
      if params[:authentication_token]
        @current_user = User.find_by_authentication_token params[:authentication_token]
      end
    end
end