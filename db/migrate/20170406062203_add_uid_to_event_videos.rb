class AddUidToEventVideos < ActiveRecord::Migration
  def change
    add_column :event_videos, :uid, :string
  end
end
