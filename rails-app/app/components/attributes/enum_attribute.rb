# frozen_string_literal: true

module Components::Attributes
  class EnumAttribute < Components::Attributes::Base
    private

    def render_value
      return unless value

      translated_value = I18n.t(
        "activerecord.attributes.#{model_class.model_name.i18n_key}.#{attribute_name}_options.#{value}",
        default: value.humanize
      )

      plain translated_value
    end
  end
end
