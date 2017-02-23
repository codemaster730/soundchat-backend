require "test_helper"

class InvitedContactTest < ActiveSupport::TestCase
  def invited_contact
    @invited_contact ||= InvitedContact.new phone_number: "+15422162006", first_name: "Nick"
  end

  def test_valid
    assert invited_contact.valid?
  end
end
