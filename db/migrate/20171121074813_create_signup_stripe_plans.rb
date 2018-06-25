class CreateSignupStripePlans < ActiveRecord::Migration
  def change
    create_table :signup_stripe_plans do |t|
      t.string :name
      t.integer :amount
      t.string :currency
      t.string :interval
      t.integer :interval_count
      t.string :plan_id

      t.timestamps null: false
    end
  end
end
