class CreateTaggedUsers < ActiveRecord::Migration
  def change
    create_table :tagged_users do |t|
      t.integer :user_id, index: true, foreign_key: true
      t.integer :post_id, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
