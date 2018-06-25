class CreateJobPlan < ActiveRecord::Migration
  def change
    JobPlan.create(name: "49$/monthly")
    JobPlan.create(name: "99$/Until Job Filled")
  end
end
