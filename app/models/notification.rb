class Notification < ActiveRecord::Base
  # Table Schema
  # t.belongs_to :user, index: true, foreign_key: true
  # t.string :message
  # t.string :sender_id
  # t.string :notif_type
  
  belongs_to :user
  # type: 0 "notification_friend_request"
  # type: 1 "notification_friend_accept"
  def sender
    User.find(self.sender_id)
  end
end
