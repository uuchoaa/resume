require "test_helper"

class Components::Form::SectionTest < ActiveSupport::TestCase
  test "renders section with title" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(
      form: form,
      title: "Personal Information"
    ).call

    assert_match(/Personal Information/, output)
    assert_match(/text-base\/7 font-semibold/, output)
  end

  test "renders section with description" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(
      form: form,
      description: "Enter your details"
    ).call

    assert_match(/Enter your details/, output)
    assert_match(/text-sm\/6 text-gray-600/, output)
  end

  test "renders section with grid layout" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(form: form).call

    assert_match(/grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6/, output)
  end

  test "renders section with border bottom" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(form: form).call

    assert_match(/border-b border-gray-900\/10/, output)
  end

  test "renders text field" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(form: form).call do |section|
      section.text :name, label: "Full Name"
    end

    assert_match(/Full Name/, output)
    assert_match(/type="text"/, output)
    assert_match(/name="name"/, output)
  end

  test "renders email field" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(form: form).call do |section|
      section.email :email, label: "Email Address"
    end

    assert_match(/Email Address/, output)
    assert_match(/type="email"/, output)
  end

  test "renders textarea field" do
    form = Components::Form.new(action: "/test")

    output = Components::Form::Section.new(form: form).call do |section|
      section.textarea :bio, label: "Bio", rows: 5
    end

    assert_match(/Bio/, output)
    assert_match(/<textarea/, output)
    assert_match(/rows="5"/, output)
  end

  test "renders select field" do
    form = Components::Form.new(action: "/test")
    options = [
      { value: "us", label: "United States" },
      { value: "ca", label: "Canada" }
    ]

    output = Components::Form::Section.new(form: form).call do |section|
      section.select :country, label: "Country", options: options
    end

    assert_match(/Country/, output)
    assert_match(/<select/, output)
    assert_match(/United States/, output)
    assert_match(/Canada/, output)
  end

  test "uses model binding for field values" do
    deal = deals(:one)
    form = Components::Form.new(action: "/deals", model: deal)

    output = Components::Form::Section.new(form: form).call do |section|
      section.text :description, label: "Description"
    end

    assert_match(/name="deal\[description\]"/, output)
    assert_match(/id="deal_description"/, output)
    assert_match(/value="#{deal.description}"/, output)
  end
end
