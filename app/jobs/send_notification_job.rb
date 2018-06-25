class SendNotificationJob < ActiveJob::Base
  queue_as :notification

  BATCH = 50
 
  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    p "****************************"
    p "SEND NOTICATION ERROR"
    p "#{exception.inspect}"
    p "**************"  
  end

  def perform action, notifiable_id, sender_id
    notifiable = nil
    sender = User.find(sender_id)
    users = []
    group = nil
    
    if action == "reply"
      notifiable = Forem::Post.find(notifiable_id)
      users = User.where(id: notifiable.topic.subscriptions.pluck(:subscriber_id))
    else # "post"
      notifiable = Forem::Topic.find(notifiable_id)
      if notifiable.forum_id == 28 
        #don't send notification when facebook PR Group
        users = nil
      else
        group = Group.where(forum_id: notifiable.forum_id).first
        # try find by name if can't find by id
        group = Group.where(name: notifiable.forum.name).first if group.nil?
        if group.nil?
          users = nil
        else
          users = group.users
        end
      end
    end
    if users != nil 
      users.each_slice(BATCH) do |user_array|
        user_array.each do |receiver|
          next if receiver.id == sender_id or !receiver.indexable?# ignore sender send notification for himself
          notification = Notification.new(action: action, 
                                          sender: sender,
                                          receiver: receiver,
                                          notifiable: notifiable)
          notification.attached_object = group if group
          notification.save
        end
      end
    end
  end
end