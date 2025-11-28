# frozen_string_literal: true

class Components::Form < Components::Base
  attr_reader :action, :method

  def initialize(action: nil, method: :post, **attributes)
    @action = action
    @method = method
    @attributes = attributes
  end

  def view_template(&block)
    form(action: @action, method: form_method, **@attributes) do
      render_method_field if spoofed_method?
      render_csrf_token

      # Container for sections
      div(class: "space-y-12") do
        yield self if block_given?
      end
    end
  end

  # Section with title, description, and grid layout
  def section(title: nil, description: nil, **attributes, &block)
    render Components::Form::Section.new(
      form: self,
      title: title,
      description: description,
      **attributes,
      &block
    )
  end

  # Action buttons at the end of the form
  def action_buttons(&block)
    render Components::Form::ActionButtons.new(form: self, &block)
  end

  # Direct field methods (without section)
  def text(name, label:, placeholder: nil, **attributes)
    input(
      type: "text",
      name: field_name(name),
      id: field_id(name),
      value: field_value(name, attributes.delete(:value)),
      placeholder: placeholder,
      class: input_classes,
      **attributes
    )
  end

  def email(name, label:, placeholder: nil, **attributes)
    input(
      type: "email",
      name: field_name(name),
      id: field_id(name),
      value: field_value(name, attributes.delete(:value)),
      placeholder: placeholder,
      class: input_classes,
      **attributes
    )
  end

  def textarea(name, label:, rows: 3, placeholder: nil, **attributes)
    value = field_value(name, attributes.delete(:value))

    super(
      name: field_name(name),
      id: field_id(name),
      rows: rows,
      placeholder: placeholder,
      class: input_classes,
      **attributes
    ) do
      plain value if value
    end
  end

  def select(name, label:, options:, **attributes)
    render Components::Select.new(
      name: field_name(name),
      id: field_id(name),
      options: options,
      selected: field_value(name, attributes.delete(:selected)),
      **attributes
    )
  end

  # Helper methods for field name/id generation (used by nested components)
  def field_name(name)
    name.to_s
  end

  def field_id(name)
    name.to_s.tr("_", "-")
  end

  def field_value(name, explicit_value)
    explicit_value
  end

  private

  def render_method_field
    input(type: "hidden", name: "_method", value: @method)
  end

  def render_csrf_token
    token = form_authenticity_token

    input(
      type: "hidden",
      name: "authenticity_token",
      value: token
    )
  rescue NoMethodError
    # CSRF token not available (e.g., in test environment)
    nil
  end

  def form_method
    %i[get post].include?(@method) ? @method.to_s : "post"
  end

  def spoofed_method?
    !%i[get post].include?(@method)
  end

  def input_classes(error: false, disabled: false)
    base = "block w-full rounded-md bg-white px-3 py-1.5 text-base outline outline-1 -outline-offset-1 sm:text-sm/6"

    if error
      "#{base} text-red-900 outline-red-300 placeholder:text-red-300 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-red-600 dark:bg-white/5 dark:text-red-400 dark:outline-red-500/50 dark:placeholder:text-red-400/70 dark:focus:outline-red-400"
    elsif disabled
      "#{base} text-gray-900 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 disabled:cursor-not-allowed disabled:bg-gray-50 disabled:text-gray-500 disabled:outline-gray-200 dark:bg-white/5 dark:text-gray-300 dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500 dark:disabled:bg-white/10 dark:disabled:text-gray-500 dark:disabled:outline-white/5"
    else
      "#{base} text-gray-900 outline-gray-300 placeholder:text-gray-400 focus:outline focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
    end
  end

  def input_aria_attributes(name, error)
    return {} unless error

    {
      "aria-invalid": "true",
      "aria-describedby": "#{field_id(name)}-error"
    }
  end
end
