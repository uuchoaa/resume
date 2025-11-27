require "test_helper"

class Components::Attributes::HasManyAttributeTest < ActiveSupport::TestCase
  def setup
    @agency = agencies(:one)
  end

  test "renders count of associated records" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: @agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    # Should show count (uses I18n so might be translated)
    assert_match(/\d+/, output)
    assert_match(/<button/, output) if @agency.deals.count > 0
  end

  test "renders zero count when no associations" do
    # Create a new agency without deals
    agency = Agency.create!(name: "Test Agency Without Deals")
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: agency.id
    ).call

    assert_match(/0/, output)
    # Should not render button when count is 0
    refute_match(/<button/, output)
  end

  test "renders button to open modal when has items" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: @agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    if @agency.deals.count > 0
      assert_match(/<button/, output)
      assert_match(/data-modal-target/, output)
      assert_match(/text-indigo-600/, output)
    end
  end

  test "generates modal with correct id" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: @agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    if @agency.deals.count > 0
      assert_match(/modal-deals-#{@agency.id}/, output)
    end
  end

  test "renders modal with list of items" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: @agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    if @agency.deals.count > 0
      # Should render modal component
      assert_match(/role="dialog"/, output)
      # Should render list
      assert_match(/<ul/, output)
      assert_match(/divide-y divide-gray-200/, output)
    end
  end

  test "renders links to associated items in modal" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: @agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    if @agency.deals.count > 0
      @agency.deals.each do |deal|
        assert_match(/href="\/deals\/#{deal.id}"/, output)
      end
    end
  end

  test "handles nil value" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: nil,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    assert_equal "", output.strip
  end

  test "renders item display name from name attribute" do
    association = Agency.reflect_on_association(:deals)

    output = Components::Attributes::HasManyAttribute.new(
      value: @agency.deals,
      attribute_name: :deals,
      model_class: Agency,
      association: association,
      item_id: @agency.id
    ).call

    # Deals don't have name, so it should use description or fallback
    if @agency.deals.count > 0
      # Should render something for each deal
      assert_match(/<li/, output)
    end
  end
end
