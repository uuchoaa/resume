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
  def field(label: nil, span: 4, description: nil, **attributes, &block)
    render Components::Form::Field.new(
      label: label,
      span: span,
      description: description,
      **attributes,
      &block
    )
  end

  # Text input field
  def text(name, label:, span: 4, placeholder: nil, description: nil, **attributes)
    field(label: label, span: span, description: description) do
      input(
        type: "text",
        name: @form.field_name(name),
        id: @form.field_id(name),
        value: @form.field_value(name, attributes.delete(:value)),
        placeholder: placeholder,
        class: input_classes,
        **attributes
      )
    end
  end

  # Email input field
  def email(name, label:, span: 4, placeholder: nil, description: nil, **attributes)
    field(label: label, span: span, description: description) do
      input(
        type: "email",
        name: @form.field_name(name),
        id: @form.field_id(name),
        value: @form.field_value(name, attributes.delete(:value)),
        placeholder: placeholder,
        class: input_classes,
        **attributes
      )
    end
  end

  # Textarea field
  def textarea(name, label:, span: :full, rows: 3, placeholder: nil, description: nil, **attributes)
    value = @form.field_value(name, attributes.delete(:value))

    field(label: label, span: span, description: description) do
      super(
        name: @form.field_name(name),
        id: @form.field_id(name),
        rows: rows,
        placeholder: placeholder,
        class: input_classes,
        **attributes
      ) do
        plain value if value
      end
    end
  end

  # Select field (integrates with existing Components::Select)
  def select(name, label:, options:, span: 3, description: nil, **attributes)
    field(label: label, span: span, description: description) do
      render Components::Select.new(
        name: @form.field_name(name),
        id: @form.field_id(name),
        options: options,
        selected: @form.field_value(name, attributes.delete(:selected)),
        **attributes
      )
    end
  end

  private

  def input_classes
    "block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
  end
end
