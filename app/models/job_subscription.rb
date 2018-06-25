class JobSubscription < ActiveRecord::Base
	belongs_to :job
	belongs_to :job_plan
end
