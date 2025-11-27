require "test_helper"

class Components::Form::ActionButtonsTest < ActiveSupport::TestCase
  test "renders action buttons container" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::ActionButtons.new(form: form).call

    assert_match(/mt-6 flex items-center justify-end gap-x-6/, output)
  end

  test "renders cancel button with default label" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::ActionButtons.new(form: form).call do |actions|
      actions.cancel
    end

    assert_match(/Cancel/, output)
    assert_match(/type="button"/, output)
    assert_match(/text-sm\/6 font-semibold text-gray-900/, output)
  end

  test "renders cancel button with custom label" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::ActionButtons.new(form: form).call do |actions|
      actions.cancel("Go Back")
    end

    assert_match(/Go Back/, output)
  end

  test "renders submit button with default label" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::ActionButtons.new(form: form).call do |actions|
      actions.submit
    end

    assert_match(/Save/, output)
    assert_match(/type="submit"/, output)
    assert_match(/bg-indigo-600/, output)
    assert_match(/hover:bg-indigo-500/, output)
  end

  test "renders submit button with custom label" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::ActionButtons.new(form: form).call do |actions|
      actions.submit("Create Deal")
    end

    assert_match(/Create Deal/, output)
  end

  test "renders both buttons together" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::ActionButtons.new(form: form).call do |actions|
      actions.cancel
      actions.submit
    end

    assert_match(/Cancel/, output)
    assert_match(/Save/, output)
  end
end
