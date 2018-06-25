class AddSummeryToJob < ActiveRecord::Migration
  def change
  	add_column :jobs, :job_summery, :string
  	add_column :jobs, :summery_of_experience, :string
  	add_column :jobs, :contact_email, :string
  	add_column :jobs, :user_id, :integer, index: true
  end
end
