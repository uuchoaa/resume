# frozen_string_literal: true

module Components::Attributes
  class BelongsToAttribute < Components::Attributes::Base
    attr_reader :association

    def initialize(value:, attribute_name:, model_class:, association:)
      super(value: value, attribute_name: attribute_name, model_class: model_class)
      @association = association
    end

    private

    def render_value
      return unless value

      related = association.klass.find_by(id: value)
      return unless related

      display_value = related.try(:name) ||
                      related.try(:title) ||
                      related.try(:email) ||
                      "#{association.klass.model_name.human} ##{related.id}"

      a(href: "/#{association.klass.model_name.route_key}/#{related.id}",
        class: "text-indigo-600 hover:text-indigo-800 underline") { display_value }
    end
  end
end
