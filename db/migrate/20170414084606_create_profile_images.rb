class CreateProfileImages < ActiveRecord::Migration
  def change
    create_table :profile_images do |t|
      t.string :image
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
