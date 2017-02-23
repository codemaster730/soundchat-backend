class Friendship < ActiveRecord::Base
  # Table schema
  # t.belongs_to :user
  # t.string :friend_id
  # t.string :status
  # t.string :type
  FRIEND_SHIP_STATUS = [:requested, :accepted, :declined]
  belongs_to :user
  belongs_to :friend, :class_name => 'User', :foreign_key =>'friend_id'

  validates :user_id, presence: true
  validates :friend_id, presence: true

  def self.add_friend user, friend
    f1 = Friendship.find user_id: user.id, friend_id: friend.id
    if f1.present?
      f1.update status: FRIEND_SHIP_STATUS[:accepted]
    else
      f1 = Friendship.create user_id:user.id, friend_id:friend.id, status: 'accepted'
    end
    f2 = Friendship.find user_id: friend.id, friend_id: user.id
    if f2.present?
      f2.update status: FRIEND_SHIP_STATUS[:accepted]
    else
      f2 = Friendship.create user_id:friend.id, friend_id:user.id, status: 'accepted'
    end
  end
end
