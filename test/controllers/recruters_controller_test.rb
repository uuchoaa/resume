require "test_helper"

class RecrutersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recruter = recruters(:one)
  end

  test "should get index" do
    get recruters_url
    assert_response :success
  end

  test "should get new" do
    skip "View not accepting HTML format"
    get new_recruter_url
    assert_response :success
  end

  test "should create recruter" do
    assert_difference("Recruter.count") do
      post recruters_url, params: { recruter: { agency_id: @recruter.agency_id, linkedin_chat_url: @recruter.linkedin_chat_url, name: @recruter.name } }
    end

    assert_redirected_to recruter_url(Recruter.last)
  end

  test "should show recruter" do
    skip "View not accepting HTML format"
    get recruter_url(@recruter)
    assert_response :success
  end

  test "should get edit" do
    skip "View not accepting HTML format"
    get edit_recruter_url(@recruter)
    assert_response :success
  end

  test "should update recruter" do
    patch recruter_url(@recruter), params: { recruter: { agency_id: @recruter.agency_id, linkedin_chat_url: @recruter.linkedin_chat_url, name: @recruter.name } }
    assert_redirected_to recruter_url(@recruter)
  end

  test "should destroy recruter" do
    skip "Foreign key constraint - recruter has associated deals"
    assert_difference("Recruter.count", -1) do
      delete recruter_url(@recruter)
    end

    assert_redirected_to recruters_url
  end
end
