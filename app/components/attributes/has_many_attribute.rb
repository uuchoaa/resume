# frozen_string_literal: true

module Components::Attributes
  class HasManyAttribute < Components::Attributes::Base
    attr_reader :association

    def initialize(value:, attribute_name:, model_class:, association:, item_id:)
      super(value: value, attribute_name: attribute_name, model_class: model_class)
      @association = association
      @item_id = item_id
    end

    private

    def render_value
      return unless value

      count = value.count
      modal_id = "modal-#{attribute_name}-#{@item_id}"
      
      # Link para abrir o modal
      button(
        type: "button",
        class: "text-blue-600 hover:text-blue-800 underline cursor-pointer",
        data_modal_target: modal_id
      ) do
        plain "#{count} #{association.klass.model_name.human(count: count)}"
      end

      # Modal com a lista de itens relacionados
      render Components::Modal.new(id: modal_id, title: association.klass.model_name.human(count: count)) do
        if count > 0
          ul(class: "divide-y divide-gray-200 dark:divide-gray-700") do
            value.each do |item|
              li(class: "py-2") do
                display_value = item.try(:name) || 
                               item.try(:title) || 
                               item.try(:email) ||
                               "#{association.klass.model_name.human} ##{item.id}"
                
                a(
                  href: "/#{association.klass.model_name.route_key}/#{item.id}",
                  class: "text-blue-600 hover:text-blue-800 underline"
                ) { display_value }
              end
            end
          end
        else
          p(class: "text-gray-500 dark:text-gray-400") { "Nenhum item encontrado" }
        end
      end
    end
  end
end
