require "test_helper"

class Components::Attributes::BelongsToAttributeTest < ActiveSupport::TestCase
  def setup
    @deal = deals(:one)
    @agency = agencies(:one)
  end

  test "renders belongs_to association as link" do
    association = Deal.reflect_on_association(:agency)

    output = Components::Attributes::BelongsToAttribute.new(
      value: @deal.agency_id,
      attribute_name: :agency_id,
      model_class: Deal,
      association: association
    ).call

    assert_match(/#{@agency.name}/, output)
    assert_match(/<a/, output)
    assert_match(/href="\/agencies\/#{@agency.id}"/, output)
  end

  test "applies link styling" do
    association = Deal.reflect_on_association(:agency)

    output = Components::Attributes::BelongsToAttribute.new(
      value: @deal.agency_id,
      attribute_name: :agency_id,
      model_class: Deal,
      association: association
    ).call

    assert_match(/text-indigo-600/, output)
    assert_match(/hover:text-indigo-800/, output)
    assert_match(/underline/, output)
  end

  test "renders nil value" do
    association = Deal.reflect_on_association(:agency)

    output = Components::Attributes::BelongsToAttribute.new(
      value: nil,
      attribute_name: :agency_id,
      model_class: Deal,
      association: association
    ).call

    assert_equal "", output.strip
  end

  test "handles invalid foreign key" do
    association = Deal.reflect_on_association(:agency)

    output = Components::Attributes::BelongsToAttribute.new(
      value: 99999,
      attribute_name: :agency_id,
      model_class: Deal,
      association: association
    ).call

    # Should render empty if record not found
    assert_equal "", output.strip
  end

  test "prefers name attribute for display" do
    association = Deal.reflect_on_association(:agency)

    output = Components::Attributes::BelongsToAttribute.new(
      value: @deal.agency_id,
      attribute_name: :agency_id,
      model_class: Deal,
      association: association
    ).call

    assert_match(/#{@agency.name}/, output)
  end

  test "renders recruiter association" do
    recruiter = recruters(:one)
    association = Deal.reflect_on_association(:recruter)

    output = Components::Attributes::BelongsToAttribute.new(
      value: @deal.recruter_id,
      attribute_name: :recruter_id,
      model_class: Deal,
      association: association
    ).call

    assert_match(/#{recruiter.name}/, output)
    assert_match(/href="\/recruters\/#{recruiter.id}"/, output)
  end
end
