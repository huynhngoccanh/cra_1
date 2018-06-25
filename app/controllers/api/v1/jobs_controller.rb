class Api::V1::JobsController < Api::V1::BaseController
	before_action :authenticate_user!
	# before_action :check_subscription
	before_action :set_job, only: [:show, :update, :destroy, :payment, :subscription_renew]
	skip_before_action :verify_authenticity_token, only: [:destroy, :create, :update]

	def index
		@jobs = Job.active_jobs
		if @jobs.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Jobs",
                      :data => { :job => @jobs.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "No Jobs..." }
    end
	end

	def my_jobs
		@jobs = current_user.jobs
		if @jobs.present?
      render :status => 200,
           :json => { :success => true,
                      :info => "Jobs",
                      :data => { :job => @jobs.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => "No Jobs..." }
    end
	end

	def create
		@job = current_user.jobs.build(job_params)
		if subscription_checkout
    	renewal_date = (params[:job][:job_plan_id].to_i ==1 ? (Time.now + 30.day) : (Time.now + 20.year))
    	@job.job_end_on = renewal_date
      if @job.save
      	@job.build_job_subscription(:job_plan_id=> params[:job][:job_plan_id], :renewal_date => renewal_date).save
        render :status => 200,
         :json => { :success => true,
                    :info => "Job was successfully created.",
                    :data => { :job => @job.as_json } }
      else
      	render :status => 400,
           :json => { :success => false,
                      :info => @job.errors.full_messages.join(",")}
      end
	  else
	  	render :status => 400,
             :json => { :success => false,
                        :info => @job.errors.full_messages.join(",")}
	  end
	end

	def update
    if @job.update(job_params)
			render :status => 200,
         :json => { :success => true,
                    :info => "Job was successfully updated.",
                    :data => { :job => @job.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => @job.errors.full_messages.join(",")}
    end
	end

	def payment
		@plans = JobPlan.all
		render :status => 200,
           :json => { :success => true,
                      :info => "All job plans.",
                      :data => { :job_plan => @plans } }
	end


	def subscription_renew
		renewal_date = (params[:job][:job_plan_id].to_i ==1 ? (Time.now + 30.day) : (Time.now + 20.year))
    @job.job_end_on = renewal_date
    if @job.save
    	@job.job_subscription.update_attributes(:job_plan_id=> params[:job][:job_plan_id], :renewal_date => renewal_date).save
      render :status => 200,
         :json => { :success => true,
                    :info => "Job was successfully updated.",
                    :data => { :job => @job.as_json } }
    else
      render :status => 400,
           :json => { :success => false,
                      :info => @job.errors.full_messages.join(",")}
    end
	end

	# def show
	# 	render :status => 200,
 #         :json => { :success => true,
 #                    :info => "Job",
 #                    :data => { :job => @job.as_json } }
	# end

	# def destroy
	# 	if @job.destroy
 #      render :status => 200,
 #           :json => { :success => true,
 #                      :info => "Job deleted successfully..." }
 #    else
 #      render :status => 400,
 #           :json => { :success => false,
 #                      :info => "Job not deleted..." }
 #    end
	# end

	private

	def set_job
    @job = Job.find(params[:id])
  end

	def job_params
		params.require(:job).permit(:title, :description, :summery_of_experience, :contact_email, :image)
	end

	def subscription_checkout
    plan = JobPlan.find params[:job][:job_plan_id]
    #This should be created on signup.
    customer = ""
    if current_user.stripe_id.nil?   
      customer = Stripe::Customer.create(
      	:description => "Customer for #{params[:job][:title]}",
        :email => current_user.email,
        :card  => params[:job][:stripeToken]
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