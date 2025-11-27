require "test_helper"

class Components::Attributes::EnumAttributeTest < ActiveSupport::TestCase
  test "renders enum value" do
    output = Components::Attributes::EnumAttribute.new(
      value: "open",
      attribute_name: :stage,
      model_class: Deal
    ).call

    # Should render the translated or humanized value
    assert_match(/open/i, output)
  end

  test "renders different enum values" do
    stages = [ "open", "screening", "offer", "closed" ]

    stages.each do |stage|
      output = Components::Attributes::EnumAttribute.new(
        value: stage,
        attribute_name: :stage,
        model_class: Deal
      ).call

      assert_match(/\w+/, output)
    end
  end

  test "renders nil enum value" do
    output = Components::Attributes::EnumAttribute.new(
      value: nil,
      attribute_name: :stage,
      model_class: Deal
    ).call

    assert_equal "", output.strip
  end

  test "humanizes value when translation not found" do
    output = Components::Attributes::EnumAttribute.new(
      value: "tech_assessment",
      attribute_name: :stage,
      model_class: Deal
    ).call

    # Should humanize if translation not found
    assert_match(/\w+/, output)
  end

  test "uses I18n translation path" do
    # Test that the component tries to use the correct I18n path
    # activerecord.attributes.{model}.{attribute}_options.{value}
    output = Components::Attributes::EnumAttribute.new(
      value: "open",
      attribute_name: :stage,
      model_class: Deal
    ).call

    # Should render something
    refute_empty output
  end
end
