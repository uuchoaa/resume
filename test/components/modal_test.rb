require "test_helper"

class Components::ModalTest < ActiveSupport::TestCase
  test "renders modal container with correct id" do
    output = Components::Modal.new(id: "test-modal", title: "Test Modal").call { "Content" }

    assert_match(/id="test-modal"/, output)
    assert_match(/hidden fixed inset-0 z-50/, output)
  end

  test "renders modal with accessibility attributes" do
    output = Components::Modal.new(id: "test-modal", title: "Test Modal").call { "Content" }

    assert_match(/role="dialog"/, output)
    assert_match(/aria-modal="true"/, output)
    assert_match(/aria-labelledby="test-modal-title"/, output)
  end

  test "renders modal title" do
    output = Components::Modal.new(id: "test-modal", title: "My Modal Title").call { "Content" }

    assert_match(/My Modal Title/, output)
    assert_match(/id="test-modal-title"/, output)
    assert_match(/text-base font-semibold text-gray-900/, output)
  end

  test "renders backdrop" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/data-modal-backdrop="test-modal"/, output)
    assert_match(/bg-gray-500\/75/, output)
    assert_match(/transition-opacity/, output)
  end

  test "renders modal panel" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/data-modal-panel="test-modal"/, output)
    assert_match(/rounded-lg bg-white/, output)
    assert_match(/shadow-xl/, output)
  end

  test "renders close button" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/data-modal-close="test-modal"/, output)
    assert_match(/type="button"/, output)
    assert_match(/<svg/, output)
  end

  test "renders close button with icon" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/size-6/, output)
    assert_match(/viewbox="0 0 24 24"/, output)
    assert_match(/stroke="currentColor"/, output)
  end

  test "renders content block" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call do
      "This is my custom content"
    end

    assert_match(/This is my custom content/, output)
  end

  test "renders with animation classes" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/transition-all duration-300 ease-out/, output)
    assert_match(/translate-y-4 opacity-0/, output)
  end

  test "renders modal structure" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/flex min-h-full items-end justify-center/, output)
    assert_match(/sm:items-center/, output)
  end

  test "renders sr-only close text" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/sr-only/, output)
    assert_match(/Close/, output)
  end

  test "renders with responsive padding" do
    output = Components::Modal.new(id: "test-modal", title: "Test").call { "Content" }

    assert_match(/px-4 pb-4 pt-5/, output)
    assert_match(/sm:p-6/, output)
  end
end
