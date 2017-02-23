require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  def friend
    u1 = User.first
    u2 = User.last
    @friend ||= Friendship.new user_id: u1.id, friend_id: u2.id
  end

  def test_valid
    assert friend.valid?
  end

  def test_user
    assert friend.user
  end

  def test_user_valid
    assert_equal friend.user, User.first
  end

  def test_friend
    assert friend.friend
  end
  def test_friend_valid
    assert_equal friend.friend, User.last
  end
end
