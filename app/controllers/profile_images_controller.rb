class ProfileImagesController < ApplicationController
  layout "application2"
  before_action :set_profile_image, only: [:show, :edit, :update, :destroy]

  # GET /profile_images
  # GET /profile_images.json
  def index
    @profile_images = ProfileImage.all
  end

  # GET /profile_images/1
  # GET /profile_images/1.json
  def show
  end

  # GET /profile_images/new
  def new
    @profile_image = current_user.profile_images.build
  end

  # GET /profile_images/1/edit
  def edit
  end

  # POST /profile_images
  # POST /profile_images.json
  def create
    respond_to do |format|
      begin
        params[:profile_image]['image'].each do |image|
          @profile_image = current_user.profile_images.create!(:image => image)
        end
        format.html { redirect_to main_app.user_path(current_user), notice: 'Profile image is successfully added.' }
        format.json { render :show, status: :created, location: @profile_image }
      rescue 
        format.html { redirect_to main_app.user_path(current_user), notice: @profile_image ? @profile_image.errors.full_messages.join(" ,") : "Please select a image" }
        format.json { render json: @profile_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profile_images/1
  # PATCH/PUT /profile_images/1.json
  def update
    respond_to do |format|
      if @profile_image.update(profile_image_params)
        format.html { redirect_to main_app.user_path(current_user), notice: 'Profile image is successfully updated.' }
        format.json { render :show, status: :ok, location: @profile_image }
      else
        format.html { render :edit }
        format.json { render json: @profile_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile_images/1
  # DELETE /profile_images/1.json
  def destroy
    @profile_image.destroy
    respond_to do |format|
      format.html { redirect_to main_app.user_path(current_user), notice: 'Profile image is successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile_image
      @profile_image = current_user.profile_images.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_image_params
      params.require(:profile_image).permit(:user_id, :image)
    end
end
