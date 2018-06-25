class CreateProfileVideos < ActiveRecord::Migration
  def change
    create_table :profile_videos do |t|
      t.string :video
      t.references :user, index: true, foreign_key: true
      t.string :uid, :string

      t.timestamps null: false
    end
  end
end
