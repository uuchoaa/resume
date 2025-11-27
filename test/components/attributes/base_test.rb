require "test_helper"

class Components::Attributes::BaseTest < ActiveSupport::TestCase
  test "renders simple value" do
    output = Components::Attributes::Base.new(
      value: "Test Value",
      attribute_name: :name,
      model_class: Agency
    ).call

    assert_match(/Test Value/, output)
  end

  test "renders nil value" do
    output = Components::Attributes::Base.new(
      value: nil,
      attribute_name: :name,
      model_class: Agency
    ).call

    refute_match(/nil/, output)
    # Should render empty
    assert_equal "", output.strip
  end

  test "truncates long values" do
    long_value = "A" * 100

    output = Components::Attributes::Base.new(
      value: long_value,
      attribute_name: :description,
      model_class: Deal
    ).call

    # Should be truncated to 50 characters
    refute_match(/A{60}/, output)
    assert_match(/\.\.\./, output)
  end

  test "does not truncate short values" do
    short_value = "Short text"

    output = Components::Attributes::Base.new(
      value: short_value,
      attribute_name: :name,
      model_class: Agency
    ).call

    assert_match(/Short text/, output)
    refute_match(/\.\.\./, output)
  end

  test "renders numeric value" do
    output = Components::Attributes::Base.new(
      value: 42,
      attribute_name: :id,
      model_class: Deal
    ).call

    assert_match(/42/, output)
  end

  test "stores attribute name and model class" do
    component = Components::Attributes::Base.new(
      value: "test",
      attribute_name: :name,
      model_class: Agency
    )

    assert_equal :name, component.attribute_name
    assert_equal Agency, component.model_class
    assert_equal "test", component.value
  end
end
