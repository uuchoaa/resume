# frozen_string_literal: true

module Components::Attributes
  class Base < Components::Base
    attr_reader :value, :attribute_name, :model_class

    def initialize(value:, attribute_name:, model_class:)
      @value = value
      @attribute_name = attribute_name
      @model_class = model_class
    end

    def view_template
      render_value
    end

    private

    def render_value
      return unless value

      text = value.to_s
      if text.length > 50
        plain text.truncate(50)
      else
        plain text
      end
    end
  end
end
