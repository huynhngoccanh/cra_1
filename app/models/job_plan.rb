class JobPlan < ActiveRecord::Base
	has_many :job_subscriptions
end
