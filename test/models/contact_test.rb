require "test_helper"

class ContactTest < ActiveSupport::TestCase
  def contact
    @contact ||= Contact.new phone_number: "+1542168004"
  end

  def test_valid
    assert contact.valid?
  end

  def test_contacts_count
    user = users(:tester1)
    assert_equal user.contacts.count, 2
  end

  def test_point
    user = users(:tester1)
    puts "Friend Count ===> #{user.contacts.first.friends_count}"
    assert_equal user.contacts.first.point, 6
  end

end
