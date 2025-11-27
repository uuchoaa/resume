module Views
  module Deals
    class New < Views::Base
      attr_accessor :deal

      def page_title
        "Novo Deal"
      end

      def view_template
        render Components::PageHeader.new(page_title)

        div(class: "mt-8 max-w-2xl mx-auto") do
          div(class: "bg-white shadow-sm ring-1 ring-gray-900/5 sm:rounded-xl") do
            div(class: "px-4 py-6 sm:p-8") do
              # Nova API simplificada usando attribute
              render Components::ModelForm.new(model: deal) do |form|
                form.attribute :agency
                form.attribute :recruter
                form.attribute :stage
                form.attribute :description

                form.action_buttons do |actions|
                  actions.cancel "Cancelar"
                  actions.submit "Criar Deal"
                end
              end
            end
          end
        end
      end
    end
  end
end
