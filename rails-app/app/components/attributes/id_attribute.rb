# frozen_string_literal: true

module Components::Attributes
  class IdAttribute < Components::Attributes::Base
    private

    def render_value
      a(href: "/#{model_class.model_name.route_key}/#{value}",
        class: "text-indigo-600 hover:text-indigo-800 underline") { value }
    end
  end
end
