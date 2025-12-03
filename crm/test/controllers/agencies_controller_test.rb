require "test_helper"

class AgenciesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get agencies_new_url
    assert_response :success
  end

  test "should get index" do
    get agencies_index_url
    assert_response :success
  end
end
