class JobsController < ApplicationController
	before_action :authenticate_user!
	# before_action :check_subscription
	before_action :set_job, only: [:show, :edit, :update, :destroy, :payment, :subscription_renew]

	def index
		@jobs = Job.active_jobs
	end

	def my_jobs
		@jobs = current_user.jobs
		render :index
	end

	def new
    @plans = JobPlan.all
		@job = current_user.jobs.new
	end

	def create
		@job = current_user.jobs.build(job_params)
		if subscription_checkout
	    respond_to do |format|
	    	renewal_date = (params[:job_plan_id].to_i ==1 ? (Time.now + 30.day) : (Time.now + 20.year))
	    	@job.job_end_on = renewal_date
	      if @job.save
	      	@job.build_job_subscription(:job_plan_id=> params[:job_plan_id], :renewal_date => renewal_date).save
	        format.html { redirect_to @job, notice: 'Job was successfully created.' }
	        format.json { render :show, status: :created, location: @job }
	      else
	        format.html { render :new }
	        format.json { render json: @job.errors, status: :unprocessable_entity }
	      end
	    end
	  else
	  	respond_to do |format|
	  		format.html { render :new }
	      format.json { render json: @job.errors, status: :unprocessable_entity }
	  	end
	  end
	end

	def edit
	end

	def update
		respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
	end

	def payment
		@plans = JobPlan.all
	end


	def subscription_renew
		respond_to do |format|
			renewal_date = (params[:job_plan_id].to_i ==1 ? (Time.now + 30.day) : (Time.now + 20.year))
	    @job.job_end_on = renewal_date
      if @job.save
      	@job.job_subscription.update_attributes(:job_plan_id=> params[:job_plan_id], :renewal_date => renewal_date).save
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
	end

	def show
	end

	def destroy
		@job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_path, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
	end

	private

	def set_job
    @job = Job.find(params[:id])
  end

	def job_params
		params.require(:job).permit(:title, :description, :summery_of_experience, :contact_email, :image)
	end

	def subscription_checkout
    plan = JobPlan.find params[:job_plan_id]
    #This should be created on signup.
    customer = ""
    if current_user.stripe_id.nil?   
      customer = Stripe::Customer.create(
      	:description => "Customer for #{params[:job][:title]}",
        :email => current_user.email,
        :card  => params[:stripeToken]
        )
    else
      customer = Stripe::Customer.retrieve(current_user.stripe_id)
    end 
    amount = plan.id == 1 ? 49 : 99
    stripe = Stripe::Charge.create(
      :customer    => customer.id,
      :amount => amount*100,
      :currency => "USD",
      :description => "#{@job.title} subscriptions"
      )
    current_user.update_attributes(:stripe_id => customer.id)
  end

  def check_subscription
  	current_user.jobs.map(&:jobs_subs)
  end

end