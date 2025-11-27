require "test_helper"

class DealsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deal = deals(:one)
  end

  test "should get index" do
    get deals_url
    assert_response :success
  end

  test "should get new" do
    skip "Template deals/new not implemented yet"
    get new_deal_url
    assert_response :success
  end

  test "should create deal" do
    skip "Template deals/new not implemented yet"
    assert_difference("Deal.count") do
      post deals_url, params: { deal: { agency_id: @deal.agency_id, recruter_id: @deal.recruter_id, stage: @deal.stage } }
    end

    assert_redirected_to deal_url(Deal.last)
  end

  test "should show deal" do
    skip "View not accepting HTML format"
    get deal_url(@deal)
    assert_response :success
  end

  test "should get edit" do
    skip "View not accepting HTML format"
    get edit_deal_url(@deal)
    assert_response :success
  end

  test "should update deal" do
    patch deal_url(@deal), params: { deal: { agency_id: @deal.agency_id, recruter_id: @deal.recruter_id, stage: @deal.stage } }
    assert_redirected_to deal_url(@deal)
  end

  test "should destroy deal" do
    assert_difference("Deal.count", -1) do
      delete deal_url(@deal)
    end

    assert_redirected_to deals_url
  end
end
