require "test_helper"

class Components::FormTest < ActiveSupport::TestCase
  test "renders form with action" do
    output = Components::Form.new(action: "/deals").call

    assert_match(/<form/, output)
    assert_match(/action="\/deals"/, output)
    assert_match(/method="post"/, output)
  end

  test "renders form with method spoofing" do
    output = Components::Form.new(action: "/deals/1", method: :patch).call

    assert_match(/method="post"/, output)
    assert_match(/<input[^>]*type="hidden"[^>]*name="_method"[^>]*value="patch"/, output)
  end

  test "renders form with space-y-12 container" do
    output = Components::Form.new(action: "/deals").call

    assert_match(/space-y-12/, output)
  end

  test "renders form with sections" do
    output = Components::Form.new(action: "/deals").call do |form|
      form.section(title: "Personal Info") do |section|
        section.text :name, label: "Name"
      end
    end

    assert_match(/Personal Info/, output)
    assert_match(/Name/, output)
  end

  test "generates field names without model" do
    form = Components::Form.new(action: "/test")

    assert_equal "email", form.field_name(:email)
  end

  test "generates field names with model" do
    deal = deals(:one)
    form = Components::Form.new(action: "/deals", model: deal)

    assert_equal "deal[description]", form.field_name(:description)
  end

  test "generates field IDs without model" do
    form = Components::Form.new(action: "/test")

    assert_equal "email", form.field_id(:email)
  end

  test "generates field IDs with model" do
    deal = deals(:one)
    form = Components::Form.new(action: "/deals", model: deal)

    assert_equal "deal_description", form.field_id(:description)
  end

  test "gets field value from model" do
    deal = deals(:one)
    form = Components::Form.new(action: "/deals", model: deal)

    assert_equal deal.description, form.field_value(:description, nil)
  end

  test "prefers explicit value over model value" do
    deal = deals(:one)
    form = Components::Form.new(action: "/deals", model: deal)

    assert_equal "explicit", form.field_value(:description, "explicit")
  end
end
