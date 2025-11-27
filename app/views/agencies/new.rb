# frozen_string_literal: true

module Views
  module Agencies
    class New < Views::Base
      attr_accessor :model

      def view_template
        render Components::PageHeader.new(
          title: "Nova Agência",
          description: "Cadastre uma nova agência de recrutamento"
        )

        div(class: "mt-8 max-w-2xl") do
          render Components::ModelForm.new(model) do |form|
            form.attribute :name
            form.action_buttons
          end
        end
      end
    end
  end
end
