# frozen_string_literal: true

class Components::Form < Components::Base
  attr_reader :action, :method, :model

  def initialize(action: nil, method: :post, model: nil, **attributes)
    @action = action
    @method = method
    @model = model
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

  # Helper methods for field name/id generation (used by nested components)
  def field_name(name)
    return name.to_s unless @model

    model_name = @model.class.model_name.param_key
    "#{model_name}[#{name}]"
  end

  def field_id(name)
    return name.to_s.tr("_", "-") unless @model

    model_name = @model.class.model_name.param_key
    "#{model_name}_#{name}"
  end

  def field_value(name, explicit_value)
    return explicit_value if explicit_value
    return nil unless @model

    @model.public_send(name) if @model.respond_to?(name)
  rescue NoMethodError
    nil
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
end
