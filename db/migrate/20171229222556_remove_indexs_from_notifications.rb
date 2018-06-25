class RemoveIndexsFromNotifications < ActiveRecord::Migration
  def change
    # remove_foreign_key :notifications, :index_notifications_on_sender_id_and_sender_type
  #  remove_index :notifications, :index_notifications_on_sender_id_and_sender_type

    
    # remove_column  :notifications, :index_notifications_on_notifiable_id_and_notifiable_type
    # remove_column  :notifications, :index_notifications_on_sender_id_and_sender_type

  end
  
end
