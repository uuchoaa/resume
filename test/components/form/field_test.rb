require "test_helper"

class Components::Form::FieldTest < ActiveSupport::TestCase
  test "renders field with label" do
    output = Components::Form::Field.new(label: "Email Address").call do
      "input content"
    end

    assert_match(/Email Address/, output)
    assert_match(/block text-sm\/6 font-medium/, output)
  end

  test "renders field without label" do
    output = Components::Form::Field.new.call do
      "input content"
    end

    refute_match(/<label/, output)
  end

  test "renders field with mt-2 wrapper" do
    output = Components::Form::Field.new(label: "Test").call do
      "input content"
    end

    assert_match(/class="mt-2"/, output)
    assert_match(/input content/, output)
  end

  test "renders field with description" do
    output = Components::Form::Field.new(
      label: "Password",
      description: "Must be at least 8 characters"
    ).call

    assert_match(/Must be at least 8 characters/, output)
    assert_match(/mt-3 text-sm\/6 text-gray-600/, output)
  end

  test "renders field with default span" do
    output = Components::Form::Field.new(label: "Test").call

    assert_match(/sm:col-span-4/, output)
  end

  test "renders field with span 2" do
    output = Components::Form::Field.new(label: "Test", span: 2).call

    assert_match(/sm:col-span-2/, output)
  end

  test "renders field with span 3" do
    output = Components::Form::Field.new(label: "Test", span: 3).call

    assert_match(/sm:col-span-3/, output)
  end

  test "renders field with full span" do
    output = Components::Form::Field.new(label: "Test", span: :full).call

    assert_match(/col-span-full/, output)
  end

  test "renders field with span 6" do
    output = Components::Form::Field.new(label: "Test", span: 6).call

    assert_match(/col-span-full/, output)
  end
end
