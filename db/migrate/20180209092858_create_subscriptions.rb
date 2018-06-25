class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :plan_id
      t.boolean :is_active

      t.timestamps null: false
    end
  end
end
