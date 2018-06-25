class CreateJobPlans < ActiveRecord::Migration
  def change
    create_table :job_plans do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
