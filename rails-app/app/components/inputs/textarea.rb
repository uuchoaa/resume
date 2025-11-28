# frozen_string_literal: true

module Components::Inputs
  class Textarea < Base
    attr_reader :rows

    def initialize(rows: 3, span: 6, **args)
      @rows = rows
      super(span: span, **args)
    end

    def view_template
      render Components::Form::Field.new(
        label: @label,
        span: @span,
        error: @error,
        field_id: @id,
        required: @required,
        hint: @hint
      ) do
        textarea(
          name: @name,
          id: @id,
          rows: @rows,
          class: input_classes(error: @error, disabled: @disabled),
          **input_aria_attributes,
          **common_input_attrs,
          **@attributes
        ) do
          plain @value if @value
        end
      end
    end
  end
end
