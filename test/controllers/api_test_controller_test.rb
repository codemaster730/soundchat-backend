require "test_helper"

class ApiTestControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

end
