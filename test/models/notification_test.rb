require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  def notification
    user = User.first
    sender = User.last
    @notification ||= Notification.new user: user, sender_id: sender.id
  end

  def test_valid
    assert notification.valid?
  end

  def test_sender
    assert_equal notification.sender, User.last
  end
end
