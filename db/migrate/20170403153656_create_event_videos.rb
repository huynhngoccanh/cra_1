class CreateEventVideos < ActiveRecord::Migration
  def change
    create_table :event_videos do |t|
      t.string :video_url
      t.references :event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
