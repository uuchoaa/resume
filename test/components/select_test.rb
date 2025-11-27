require "test_helper"

class Components::SelectTest < ActiveSupport::TestCase
  test "renders select button" do
    options = [
      { value: "option1", label: "Option 1" },
      { value: "option2", label: "Option 2" }
    ]

    output = Components::Select.new(name: "test", options: options).call

    assert_match(/<button/, output)
    assert_match(/data-select-target="button"/, output)
    assert_match(/data-action="click->select#toggle"/, output)
  end

  test "renders hidden input with name" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(name: "user[role]", options: options).call

    assert_match(/name="user\[role\]"/, output)
    assert_match(/data-select-target="hiddenInput"/, output)
    assert_match(/type="hidden"/, output)
  end

  test "renders label when provided" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(name: "test", options: options, label: "Choose option").call

    assert_match(/<label/, output)
    assert_match(/Choose option/, output)
    assert_match(/block text-sm font-medium text-gray-900/, output)
  end

  test "renders without label when not provided" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(name: "test", options: options).call

    refute_match(/<label/, output)
  end

  test "renders options menu" do
    options = [
      { value: "option1", label: "Option 1" },
      { value: "option2", label: "Option 2" },
      { value: "option3", label: "Option 3" }
    ]

    output = Components::Select.new(name: "test", options: options).call

    assert_match(/Option 1/, output)
    assert_match(/Option 2/, output)
    assert_match(/Option 3/, output)
    assert_match(/data-select-target="menu"/, output)
  end

  test "renders selected option with checkmark" do
    options = [
      { value: "option1", label: "Option 1" },
      { value: "option2", label: "Option 2" }
    ]

    output = Components::Select.new(
      name: "test",
      options: options,
      selected: "option2"
    ).call

    assert_match(/Option 2/, output)
    # Checkmark SVG should be present
    assert_match(/size-5/, output)
  end

  test "displays selected label in button" do
    options = [
      { value: "option1", label: "Option 1" },
      { value: "option2", label: "Option 2" }
    ]

    output = Components::Select.new(
      name: "test",
      options: options,
      selected: "option2"
    ).call

    assert_match(/data-select-target="selectedText"/, output)
    assert_match(/Option 2/, output)
  end

  test "displays placeholder when nothing selected" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(name: "test", options: options).call

    assert_match(/Selecione.../, output)
  end

  test "renders with custom id" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(
      name: "test",
      options: options,
      label: "Test Label",
      id: "custom-select-id"
    ).call

    # ID is used in the label's "for" attribute
    assert_match(/for="custom-select-id"/, output)
  end

  test "generates id automatically when not provided" do
    options = [ { value: "option1", label: "Option 1" } ]

    component = Components::Select.new(name: "test_name", options: options, label: "Test")
    output = component.call

    # Check that an id is present in the output
    assert_match(/for="select_test_name_\d+"/, output)
  end

  test "renders chevron icon" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(name: "test", options: options).call

    assert_match(/<svg/, output)
    assert_match(/viewBox="0 0 16 16"/, output)
    assert_match(/size-5/, output)
  end

  test "renders option with data attributes" do
    options = [ { value: "test_value", label: "Test Label" } ]

    output = Components::Select.new(name: "test", options: options).call

    assert_match(/data-select-target="option"/, output)
    assert_match(/data-value="test_value"/, output)
    assert_match(/data-label="Test Label"/, output)
    assert_match(/data-action="click->select#selectOption"/, output)
  end

  test "applies correct styling classes" do
    options = [ { value: "option1", label: "Option 1" } ]

    output = Components::Select.new(name: "test", options: options).call

    assert_match(/rounded-md bg-white/, output)
    assert_match(/outline-gray-300/, output)
    assert_match(/focus-visible:outline-indigo-600/, output)
    assert_match(/hover:bg-indigo-600/, output)
  end
end
