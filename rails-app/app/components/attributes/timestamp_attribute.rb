# frozen_string_literal: true

module Components::Attributes
  class TimestampAttribute < Components::Attributes::Base
    private

    def render_value
      return unless value

      case value
      when Time, DateTime, ActiveSupport::TimeWithZone
        plain I18n.l(value, format: :short)
      when Date
        plain I18n.l(value, format: :short)
      else
        plain value.to_s
      end
    end
  end
end
