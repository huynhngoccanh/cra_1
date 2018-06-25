class CreateJobSubscriptions < ActiveRecord::Migration
  def change
    create_table :job_subscriptions do |t|
      t.string :plan_id
      t.integer :job_id
      t.date :renewal_date

      t.timestamps null: false
    end
  end
end
