require "test_helper"

class Components::Attributes::TimestampAttributeTest < ActiveSupport::TestCase
  test "renders Time object" do
    time = Time.new(2025, 11, 27, 14, 30, 0)

    output = Components::Attributes::TimestampAttribute.new(
      value: time,
      attribute_name: :created_at,
      model_class: Deal
    ).call

    # Should use I18n.l with short format
    assert_match(/2025/, output)
    assert_match(/11/, output)
    assert_match(/27/, output)
  end

  test "renders DateTime object" do
    datetime = DateTime.new(2025, 11, 27, 14, 30, 0)

    output = Components::Attributes::TimestampAttribute.new(
      value: datetime,
      attribute_name: :updated_at,
      model_class: Deal
    ).call

    assert_match(/2025/, output)
  end

  test "renders Date object" do
    date = Date.new(2025, 11, 27)

    output = Components::Attributes::TimestampAttribute.new(
      value: date,
      attribute_name: :created_at,
      model_class: Deal
    ).call

    assert_match(/2025/, output)
    assert_match(/11/, output)
    assert_match(/27/, output)
  end

  test "renders ActiveSupport::TimeWithZone object" do
    time_with_zone = Time.zone.local(2025, 11, 27, 14, 30, 0)

    output = Components::Attributes::TimestampAttribute.new(
      value: time_with_zone,
      attribute_name: :created_at,
      model_class: Deal
    ).call

    assert_match(/2025/, output)
  end

  test "renders nil value" do
    output = Components::Attributes::TimestampAttribute.new(
      value: nil,
      attribute_name: :created_at,
      model_class: Deal
    ).call

    assert_equal "", output.strip
  end

  test "handles non-timestamp values" do
    output = Components::Attributes::TimestampAttribute.new(
      value: "not a timestamp",
      attribute_name: :created_at,
      model_class: Deal
    ).call

    assert_match(/not a timestamp/, output)
  end
end
