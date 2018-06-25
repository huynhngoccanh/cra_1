module CzardomAdmin  
  class JobsController < AdminController
    # load_and_authorize_resource class: 'Job'
    before_action :set_job, only: [:show, :edit, :update, :destroy]

    def index
      @jobs = current_user.jobs.page(params[:page]).per(15).order('updated_at DESC')
      respond_with @jobs
    end

    def show
      respond_with @job
    end

    def new
      @job = Job.new
      respond_with @job
    end

    def create
      @job = current_user.jobs.build(job_params)
      respond_to do |format|
        if @job.save
          format.html { redirect_to jobs_path, notice: 'Job was successfully created.' }
          format.json { render :show, status: :created, location: @job }
        else
          format.html { render :new }
          format.json { render json: @job.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      respond_with @job
    end

    def update
      @job.update_attributes(job_params)
      redirect_to jobs_path
    end

    def destroy
      @job.destroy
      respond_with @job
    end

    private

    def job_params
      params.require(:job).permit(:job_end_on, :title, :description, :summery_of_experience, :contact_email, :image, :user_id)
    end

    def set_job
      @job = Job.find params[:id]
    end

  end
end