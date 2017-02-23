class User < ActiveRecord::Base
  # table schema
  # t.string :email
  # t.string :user_name
  # t.string :first_name
  # t.string :last_name
  # t.string :phone_number
  # t.string :digital_code
  # t.string :token
  # t.string :device_token
  # t.integer :badge_count, default: 0
  # t.integer :point, default: 0
  # t.boolean :verified
  # validates :phone_number, presence: true, uniqueness: true, phone: {possible: false, allow_blank: true, types:[:mobile]}
  validates :phone_number, presence: true, uniqueness: true, phone: {possible: false, allow_blank: true}
  validates :user_name, uniqueness: true, :allow_blank => true, :allow_nil => true
  validates :digital_code, presence: true

  has_many :friendships, dependent: :destroy
  # has_many :friends, :through => :friendships, :conditions => "status = 'accepted'"
  has_many :friends, -> {where(friendships: {status: 'accepted'}).order('created_at DESC')}, class_name: "Friendship"
  has_many :requested_friends, -> {where(friendships: {status: 'requested'}).order('created_at DESC')}, class_name: "Friendship"
  has_many :pending_friends, -> {where(friendships: {status: 'pending'}).order('created_at DESC')}, class_name: "Friendship"
  has_many :notifications, dependent: :destroy

  has_many :contacts, dependent: :destroy
  has_many :no_member_of_contacts, -> {where(contacts: {is_member: false})}, class_name: "Contact"
  has_many :invited_contacts, dependent: :destroy

  after_create :reminder

  def full_name
    [self.first_name, self.last_name].join(' ')
  end

  def reminder
    @twilio_number = ENV['TWILIO_NUMBER']
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    reminder = "Hi, Please use this number #{digital_code}"
    message = @client.account.messages.create(
      :from => @twilio_number,
      :to => self.phone_number,
      :body => reminder,
    )
    puts message.to
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(token: random_token)
    end
  end

  def self.digital_code
    (0...4).map{rand(9)}.join
  end

  def invite_friend frd
    friend = Friendship.where({user_id:self.id, friend_id:frd.id}).first
    message = "#{self.user_name} added you"
    if friend.present?
      if friend.status == 'accepted'
        msg = "This user is already added to friend list"
      else
        frd.update(badge_count:frd.badge_count+1)
        frd.notifications.create(sender_id:self.id,message:message, notif_type: 0)
        APNS.send_notification(frd.device_token, alert:message, badge:frd.badge_count, sound: 'default',
          :other => {:sent => self.id, :type => 0})
      end
    else
      friend1 = Friendship.new user_id:self.id, friend_id:frd.id, status: 'requested'
      friend2 = Friendship.new user_id:frd.id, friend_id:self.id, status: 'pending'
      if friend1.save and friend2.save
        frd.update(badge_count:frd.badge_count+1)
        frd.notifications.create(sender_id:self.id, message:message, notif_type: 0)
        APNS.send_notification(frd.device_token, alert:message, badge:frd.badge_count, sound: 'default',
          :other => {:sent => self.id, :type => 0})
      end
      msg = "Sent invite request to #{frd.user_name}"
    end
    return msg
  end

  def accept_request friend, state
    if state == 0
      status = 'declined'
    else
      status = 'accepted'
    end
    message = "#{self.user_name} #{status} you"
    friend1 = Friendship.where({user_id:self.id, friend_id:friend.id}).first
    friend2 = Friendship.where({user_id:friend.id,friend_id:self.id}).first
    if friend1.update(status: status) and friend2.update(status: status)
      friend.update(badge_count:friend.badge_count+1)
      friend.notifications.create(sender_id:self.id,message:message, notif_type: 1)
      APNS.send_notification(friend.device_token, alert:message, badge:friend.badge_count, sound: 'default',
        :other => {:sent => self.id, :type => 1})
    end
    status
  end

  # friends is search results that found using the phone numbers of user contact list
  def add_friends friends
    user = self
    friends.each do |ff|
      f1 = Friendship.where(user_id: ff[:user_id], friend_id: ff[:friend_id])
      f1 = f1.first
      if f1.present?
        f1.update status: "accepted"
      else
        f1 = Friendship.new user_id:ff[:user_id], friend_id:ff[:friend_id], status: 'accepted'
      end

      f2 = Friendship.where(user_id:ff[:friend_id], friend_id:ff[:user_id])
      f2 = f2.first
      if f2.present?
        f2.update status: "accepted"
      else
        f2 = Friendship.new user_id:ff[:friend_id], friend_id:ff[:user_id], status: 'accepted'
      end
      contact = f2.friend.contacts.find_by_phone_number(self.phone_number)
      message = "#{self.phone_number} has joined and is now your friend!"
      if contact.present? and !contact.full_name.blank?
        message = "#{contact.full_name} has joined and is now your friend!"
        if self.user_name.present?
          message = "#{contact.full_name}(#{self.user_name}) has joined and is now your friend!"
        end
      else
        if self.full_name.present? and self.user_name.present?
          message = "#{self.full_name}(#{self.user_name}) has joined and is now your friend!"
        elsif self.user_name.present?
          message = "#{self.user_name} has joined and is now your friend!"
        elsif self.full_name.present?
          message = "#{self.full_name} has joined and is now your friend!"
        else
          message = "#{self.phone_number} has joined and is now your friend!"
        end
      end

      if f1.save and f2.save
        f2.friend.update(badge_count: f2.friend.badge_count.to_i + 1)
        puts "message===> #{message}"
        f2.friend.notifications.create(sender_id:self.id,message:message, notif_type: 0)
        APNS.send_notification(f2.friend.device_token, alert:message, badge:f2.friend.badge_count, sound: 'default',
          :other => {:sent => self.id, :type => 0})
      end
    end
  end

  def add_friend friend
    Friendship.add_friend self, friend
    message = "#{self.user_name} added you"
    APNS.send_notification(friend.device_token, alert:message, badge:friend.badge_count, sound: 'default',
      :other => {:sent => self.id, :type => 0})
  end

  def friends_by_json
    friend_list = []
    self.friends.each do |ff|
      friend = ff.friend
      friend_list<<{
        id: friend.id.to_s,
        phone_number: friend.phone_number,
        first_name: friend.first_name,
        last_name: friend.last_name,
        user_name: friend.user_name
      }
    end
    friend_list
  end

  def notifications_by_json
    notif_list = []
    self.notifications.each do |notif|
      notif_list<<{
        id: notif.id,
        msg: notif.message,
        sender: notif.sender_id,
        type: notif.notif_type,
        sent_at:notif.created_at.to_formatted_s(:db)
      }
    end
    notif_list
  end

  def info_by_json
    user_info = {
      token: self.token,
      first_name: self.first_name,
      last_name: self.last_name,
      user_name: self.user_name,
      phone_number: self.phone_number,
      point: self.point,
      friends: self.friends_by_json,
      notifications: self.notifications_by_json,
      contacts: self.no_member_of_contacts_by_json
    }
    user_info
  end

  def no_member_of_contacts_by_json
    contacts = []
    self.no_member_of_contacts.each do |contact|
      contacts << {
        phone_number: contact.phone_number,
        friends_count: contact.friends_count,
        point: contact.point
      }
    end
    contacts
  end

  def increase_point point, user = nil
    self.update point: self.point + point
    if user != nil
      message = "#{user.user_name} is verified"
      APNS.send_notification(self.device_token, alert:message, badge:self.badge_count+1, sound: 'default',
        :other => {:sent => user.id, :type => 2, point: point})
    end
  end

  def update_contacts contact_list
    contact_list.each do |item|
      first_name = item[0].split(' ')[0]
      last_name = item[0].split(' ')[1]
      contact = self.contacts.find_by_phone_number item[1]
      contacts = Contact.where(phone_number: phone_number)
      f_count = contacts.present? ? contacts.count - 1 : 0
      is_member = User.find_by_phone_number(phone_number).present?
      if contact.present?
        contact.update friends_count: f_count, is_member: is_member, first_name: first_name, last_name: last_name
      else
        contact = self.contacts.create phone_number:phone_number, friends_count: f_count, is_member: is_member, first_name: first_name, last_name: last_name
      end
    end
  end

  def self.find_by_contact_numbers phone_numbers
    friends = []
    phone_numbers.each do |phone_number|
      if phone_number.length > 9
        qry = []
        for i in 0..phone_number.length-9
          number = phone_number[i,9]
          qry << "phone_number LIKE '%#{number}%'"
        end
        friends << User.where(qry.join(" OR ")).map{|u| u.id}
      else
        friends << User.where("phone_number LIKE ?", "%#{phone_number}%").map{|u| u.id}
      end
    end
    friends.flatten.uniq
  end

  handle_asynchronously :reminder , :run_at => Proc.new { 3.seconds.from_now }
end
