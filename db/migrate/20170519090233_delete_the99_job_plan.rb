class DeleteThe99JobPlan < ActiveRecord::Migration
  def up
  	job = JobPlan.find_by_name "99$/Until Job Filled"
  	job.destroy
  end

  def down
  	JobPlan.create(name: "99$/Until Job Filled")
  end
end
