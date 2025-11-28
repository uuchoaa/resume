# Example usage of Components::Form

# Simple form
render Components::Form.new(action: deals_path, method: :post) do |form|
  form.section(title: "Deal Information") do |section|
    section.email :email, label: "Candidate Email", span: 4
    section.textarea :description, label: "Description", span: :full
    section.select :stage, label: "Stage", span: 3, options: [
      { value: "open", label: "Open" },
      { value: "screening", label: "Screening" }
    ]
  end

  form.action_buttons do |actions|
    actions.cancel
    actions.submit "Create Deal"
  end
end

# Form with model binding
@deal = Deal.new
render Components::Form.new(action: deals_path, model: @deal) do |form|
  form.section(title: "Profile", description: "This information will be displayed publicly") do |section|
    section.text :first_name, label: "First name", span: 3
    section.text :last_name, label: "Last name", span: 3
    section.email :email, label: "Email address", span: 4
  end

  form.section(title: "Additional Information") do |section|
    section.textarea :bio, 
      label: "About", 
      span: :full,
      rows: 3,
      description: "Write a few sentences about yourself."
  end

  form.action_buttons do |actions|
    actions.cancel "Cancel"
    actions.submit "Save"
  end
end
