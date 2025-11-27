# frozen_string_literal: true

module Views
  module DefaultCruds
    class New < Views::Base
      attr_accessor :model

      def page_title
        "Novo #{model.model_name.human}" if model.respond_to?(:model_name)
      end

      def view_template
        render Components::PageHeader.new(page_title)

        div(class: "mt-8 max-w-2xl mx-auto") do
          div(class: "bg-white shadow-sm ring-1 ring-gray-900/5 sm:rounded-xl dark:bg-gray-800 dark:ring-white/10") do
            div(class: "px-4 py-6 sm:p-8") do
              render Components::ModelForm.new(model: model) do |form|
                form.attributes do
                  form_attributes.each do |attr|
                    form.attribute attr
                  end
                end

                form.action_buttons
              end
            end
          end
        end
      end

      private

      def form_attributes
        model_class = model.class

        # Lista de atributos a ignorar
        ignore_attrs = %w[id created_at updated_at]

        # Pega todos os atributos do model
        attrs = model_class.attribute_names.reject { |attr| ignore_attrs.include?(attr) }

        # Adiciona associações belongs_to
        model_class.reflect_on_all_associations(:belongs_to).each do |assoc|
          attrs << assoc.name unless attrs.include?(assoc.name.to_s)
        end

        # Adiciona enums
        model_class.defined_enums.keys.each do |enum_name|
          attrs << enum_name unless attrs.include?(enum_name)
        end

        attrs.map(&:to_sym)
      end
    end
  end
end
