require "test_helper"

class AccountsApiTest < Minitest::Test
  include Rack::Test::Methods
  def app
    API
  end
  def test_ping
    get '/api/v1/accounts/ping'
    ping_status = { "ping"=>"accounts test"}
    assert last_response.ok?
    assert_equal ping_status, JSON.parse(last_response.body)
  end

end
