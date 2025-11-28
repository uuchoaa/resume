# frozen_string_literal: true

module Components::Inputs
  class Email < Base
    def view_template
      render Components::Form::Field.new(
        label: @label,
        span: @span,
        error: @error,
        field_id: @id,
        required: @required,
        hint: @hint
      ) do
        input(
          type: "email",
          name: @name,
          id: @id,
          value: @value,
          class: input_classes(error: @error, disabled: @disabled),
          **input_aria_attributes,
          **common_input_attrs,
          **@attributes
        )
      end
    end
  end
end
