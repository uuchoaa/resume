require "test_helper"

class Components::BaseTest < ActiveSupport::TestCase
  test "inherits from Phlex::HTML" do
    assert Components::Base < Phlex::HTML
  end

  test "includes Rails route helpers" do
    assert Components::Base.include?(Phlex::Rails::Helpers::Routes)
  end

  test "includes form authenticity token helper" do
    assert Components::Base.include?(Phlex::Rails::Helpers::FormAuthenticityToken)
  end

  test "can render basic component" do
    component = Class.new(Components::Base) do
      def view_template
        div { "test content" }
      end
    end

    output = component.new.call

    assert_match(/test content/, output)
    assert_match(/<div/, output)
  end
end
