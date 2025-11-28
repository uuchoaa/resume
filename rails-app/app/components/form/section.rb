# frozen_string_literal: true

class Components::Form::Section < Components::Base
  def initialize(form:, title: nil, description: nil, **attributes)
    @form = form
    @title = title
    @description = description
    @attributes = attributes
  end

  def view_template(&block)
    div(
      class: "border-b border-gray-900/10 pb-12 dark:border-white/10",
      **@attributes
    ) do
      # Section header
      if @title || @description
        h2(class: "text-base/7 font-semibold text-gray-900 dark:text-white") do
          plain @title
        end if @title

        p(class: "mt-1 text-sm/6 text-gray-600 dark:text-gray-400") do
          plain @description
        end if @description
      end

      # Grid container for fields
      div(class: "mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6") do
        yield self if block_given?
      end
    end
  end

  # Field wrapper with label and description support
  def field(label: nil, span: 4, description: nil, error: nil, **attributes, &block)
    render Components::Form::Field.new(
      label: label,
      span: span,
      description: description,
      error: error,
      **attributes,
      &block
    )
  end

  # Text input field
  def text(name, label:, span: 4, placeholder: nil, description: nil, error: nil, disabled: false, **attributes)
    field_id = @form.field_id(name)
    error = error_for(name, error)

    field(label: label, span: span, description: description, error: error, field_id: field_id) do
      input(
        type: "text",
        name: @form.field_name(name),
        id: field_id,
        value: @form.field_value(name, attributes.delete(:value)),
        placeholder: placeholder,
        disabled: disabled,
        class: @form.send(:input_classes, error: error, disabled: disabled),
        **@form.send(:input_aria_attributes, name, error),
        **attributes
      )
    end
  end

  # Email input field
  def email(name, label:, span: 4, placeholder: nil, description: nil, error: nil, disabled: false, **attributes)
    field_id = @form.field_id(name)
    error = error_for(name, error)

    field(label: label, span: span, description: description, error: error, field_id: field_id) do
      input(
        type: "email",
        name: @form.field_name(name),
        id: field_id,
        value: @form.field_value(name, attributes.delete(:value)),
        placeholder: placeholder,
        disabled: disabled,
        class: @form.send(:input_classes, error: error, disabled: disabled),
        **@form.send(:input_aria_attributes, name, error),
        **attributes
      )
    end
  end

  # Textarea field
  def textarea(name, label:, span: :full, rows: 3, placeholder: nil, description: nil, error: nil, disabled: false, **attributes)
    field_id = @form.field_id(name)
    value = @form.field_value(name, attributes.delete(:value))
    error = error_for(name, error)

    field(label: label, span: span, description: description, error: error, field_id: field_id) do
      super(
        name: @form.field_name(name),
        id: field_id,
        rows: rows,
        placeholder: placeholder,
        disabled: disabled,
        class: @form.send(:input_classes, error: error, disabled: disabled),
        **@form.send(:input_aria_attributes, name, error),
        **attributes
      ) do
        plain value if value
      end
    end
  end

  private

  def error_for(name, explicit_error)
    return explicit_error unless explicit_error.nil?
    return nil unless @form.respond_to?(:field_error)

    @form.field_error(name)
  end

  public

  # Select field (integrates with existing Components::Select)
  def select(name, label:, options:, span: 3, description: nil, error: nil, disabled: false, **attributes)
    field_id = @form.field_id(name)
    selected_value = @form.field_value(name, attributes.delete(:selected))
    error = error_for(name, error)

    # Add ARIA attributes manually since input_aria_attributes is private
    aria_attrs = {}
    if error
      aria_attrs[:"aria-invalid"] = "true"
      aria_attrs[:"aria-describedby"] = "#{field_id}-error"
    end

    field(label: label, span: span, description: description, error: error, field_id: field_id) do
      render Components::Select.new(
        name: @form.field_name(name),
        id: field_id,
        options: options,
        selected: selected_value,
        disabled: disabled,
        error: error,
        **aria_attrs,
        **attributes
      )
    end
  end
end
