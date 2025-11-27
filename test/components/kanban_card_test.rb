require "test_helper"

class Components::KanbanCardTest < ActiveSupport::TestCase
  def setup
    @deal = deals(:one)
  end

  test "renders deal description" do
    output = render_component(@deal)

    assert_match(/#{@deal.description[0..50]}/, output)
    assert_match(/font-semibold text-gray-900/, output)
  end

  test "truncates long description" do
    long_description = "A" * 100
    @deal.update(description: long_description)

    output = render_component(@deal)

    # Should be truncated to 60 characters
    refute_match(/A{70}/, output)
  end

  test "renders agency name" do
    output = render_component(@deal)

    assert_match(/#{@deal.agency.name}/, output)
    assert_match(/🏢/, output)
  end

  test "renders recruiter name" do
    output = render_component(@deal)

    assert_match(/#{@deal.recruter.name}/, output)
    assert_match(/👤/, output)
  end

  test "renders created date" do
    output = render_component(@deal)

    assert_match(/📅/, output)
    # Date should be formatted
    assert_match(/\d{2}\/\d{2}\/\d{4}/, output)
  end

  test "renders card with correct styling" do
    output = render_component(@deal)

    assert_match(/bg-white rounded-lg shadow p-4 mb-3/, output)
    assert_match(/hover:shadow-md transition/, output)
  end

  test "renders details link" do
    output = render_component(@deal)

    assert_match(/Ver detalhes →/, output)
    assert_match(/href="\/deals\/#{@deal.id}"/, output)
    assert_match(/text-indigo-600/, output)
  end

  test "renders stage form" do
    output = render_component(@deal)

    assert_match(/<form/, output)
    assert_match(/action="\/deals\/#{@deal.id}"/, output)
    assert_match(/method="post"/, output)
  end

  test "includes PATCH method in form" do
    output = render_component(@deal)

    assert_match(/name="_method"/, output)
    assert_match(/value="patch"/, output)
  end

  test "includes CSRF token in form" do
    output = render_component(@deal)

    assert_match(/name="authenticity_token"/, output)
    assert_match(/type="hidden"/, output)
  end

  test "renders stage select component" do
    output = render_component(@deal)

    assert_match(/name="deal\[stage\]"/, output)
    assert_match(/Estágio/, output)
  end

  test "renders with turbo frame" do
    output = render_component(@deal)

    assert_match(/data-turbo-frame="_top"/, output)
  end

  test "renders all information sections" do
    output = render_component(@deal)

    assert_match(/space-y-2 text-sm text-gray-600/, output)
    assert_match(/flex items-center gap-2/, output)
  end

  private

  def render_component(deal)
    component = Components::KanbanCard.new(deal: deal)

    # Mock form_authenticity_token
    component.define_singleton_method(:form_authenticity_token) do
      "mock_csrf_token_12345"
    end

    # Mock deal_path helper
    component.define_singleton_method(:deal_path) do |d|
      "/deals/#{d.id}"
    end

    component.call
  end
end
