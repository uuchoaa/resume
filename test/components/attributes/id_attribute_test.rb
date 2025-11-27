require "test_helper"

class Components::Attributes::IdAttributeTest < ActiveSupport::TestCase
  test "renders id as link" do
    output = Components::Attributes::IdAttribute.new(
      value: 123,
      attribute_name: :id,
      model_class: Agency
    ).call

    assert_match(/123/, output)
    assert_match(/<a/, output)
    assert_match(/href="\/agencies\/123"/, output)
  end

  test "applies link styling" do
    output = Components::Attributes::IdAttribute.new(
      value: 456,
      attribute_name: :id,
      model_class: Deal
    ).call

    assert_match(/text-indigo-600/, output)
    assert_match(/hover:text-indigo-800/, output)
    assert_match(/underline/, output)
  end

  test "uses correct route for different models" do
    agency_output = Components::Attributes::IdAttribute.new(
      value: 1,
      attribute_name: :id,
      model_class: Agency
    ).call

    deal_output = Components::Attributes::IdAttribute.new(
      value: 2,
      attribute_name: :id,
      model_class: Deal
    ).call

    assert_match(/href="\/agencies\/1"/, agency_output)
    assert_match(/href="\/deals\/2"/, deal_output)
  end

  test "renders with string id" do
    output = Components::Attributes::IdAttribute.new(
      value: "abc-123",
      attribute_name: :id,
      model_class: Agency
    ).call

    assert_match(/abc-123/, output)
    assert_match(/href="\/agencies\/abc-123"/, output)
  end
end
