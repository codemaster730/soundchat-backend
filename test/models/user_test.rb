require "test_helper"

class UserTest < ActiveSupport::TestCase
  def user
    @user = User.new phone_number: '+8613050387411', digital_code: '2178'
    @user1 = User.new phone_number: '+8613050386450', digital_code: '4168'
  end

  def test_valid
    assert user.valid?
  end

  def test_friendship
    assert user.friendships
  end

  def test_friends
    assert user.friends
  end

  def test_requested_friends
    assert user.requested_friends
  end

  def test_pending_friends
    assert user.pending_friends
  end

  def test_generate_token
    user = users(:tester1)
    tokens = User.all.map { |u| u.token }
    token = user.generate_token
    assert_not_equal(tokens.include?(token), true)
  end

  def test_invite_friend
    user = users(:tester1)
    friend = users(:tester2)
    user.invite_friend friend
    assert user.friendships.count > 0
    friend_ship = user.friendships.find_by_friend_id friend.id
    assert_equal friend_ship.status, "requested"
    assert_equal friend_ship.friend, friend
  end

  def test_accept_request
    user = users(:tester1)
    friend = users(:tester2)
    friend1 = users(:tester3)

    user.invite_friend friend
    friend.accept_request user, 1
    assert user.friendships.count > 0
    friend_ship = user.friendships.find_by_friend_id friend.id
    assert_equal friend_ship.status, "accepted"
    friend_ids = user.friends.map { |f| f.friend_id }
    assert_equal friend_ids.include?(friend.id.to_s), true

    friend1.invite_friend friend
    friend.accept_request friend1, 0
    friend_ship = friend1.friendships.find_by_friend_id friend.id
    assert_equal friend_ship.status, "declined"
    friend_ids = user.friends.map { |f| f.friend_id }
    assert_equal friend_ids.include?(friend1.id.to_s), false
  end

  def test_add_friends
    user = users(:tester1)
    users(:tester2).contacts.create(phone_number: user.phone_number, first_name:'FContact', last_name: 'Lc')
    contacts = "#{users(:tester2).phone_number}:#{users(:tester2).full_name},#{users(:tester3).phone_number}:#{users(:tester3).full_name},#{users(:tester4).phone_number}:#{users(:tester4).full_name},#{users(:tester5).phone_number}:#{users(:tester5).full_name}"
    contacts = contacts.split(",").map{|cc| cc.split(':')}
    puts contacts
    phone_numbers = contacts.map{|cc| cc[0]}
    puts "phone_numbers=#{phone_numbers}"
    ids_by_contact = User.find_by_contact_numbers(phone_numbers)
    puts "ids_by_contact = #{ids_by_contact}"

    assert_equal phone_numbers.length == ids_by_contact.length, true
    ids_by_contact.delete_if{|uid| uid == user.id}
    # assert_equal phone_numbers.length == ids_by_contact.length, false
    phone_numbers.delete_if{|pnum| pnum==user.phone_number}
    # add contacts
    user.update_contacts contacts
    assert_equal user.contacts.count >= phone_numbers.count, true

    # friends test
    assert_equal user.friends.count >= ids_by_contact.count, false

    # add friends
    friend_conditions = ids_by_contact.map{|u_id| {user_id:u_id,friend_id:user.id}}
    puts "friend_conditions = #{friend_conditions}"
    user.add_friends friend_conditions
    puts "friends count = #{user.friends.count}"
    puts "ids_by_contact = #{ids_by_contact.count}"
    assert_equal user.friends.count >= ids_by_contact.count, true

    # APNS test
    user.friends.each do |friend|
      assert_equal friend.friend.notifications.count >= 1, true
      # assert_equal friend.friend.badge_count >= 1, true
    end

  end

  def test_update_contacts

  end

  def test_update_point
    user = users(:tester1)
    point = user.point
    user.increase_point 5
    assert_equal user.point - 5 == point, true
  end
end
