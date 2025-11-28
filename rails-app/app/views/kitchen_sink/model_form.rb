# frozen_string_literal: true

module Views
  module KitchenSink
    class ModelForm < Views::Base
      def page_title
        "ModelForm - Kitchen Sink"
      end

      def view_template
        render Components::PageHeader.new(
          title: page_title,
          description: "Exemplos de uso da API simplificada do ModelForm"
        )

        div(class: "mt-8 space-y-12 max-w-4xl mx-auto") do
          basic_example
          default_buttons_example
          customization_examples
          layout_examples
          validation_examples
        end
      end

      private

      def basic_example
        section_card("Basic Usage", "API simplificada que detecta automaticamente o tipo de campo") do
          code_block do
            plain <<~CODE
              render Components::ModelForm.new(model: deal) do |form|
                form.attributes do
                  form.attribute :agency
                  form.attribute :recruter
                  form.attribute :stage
                  form.attribute :description
                end

                # Botões padrão (Cancelar + Salvar) via I18n
                form.action_buttons
              end
            CODE
          end

          div(class: "mt-6") do
            render Components::ModelForm.new(model: Deal.new) do |form|
              form.attributes do
                form.attribute :agency
                form.attribute :recruter
                form.attribute :stage
                form.attribute :description
              end

              form.action_buttons
            end
          end
        end
      end

      def default_buttons_example
        section_card("Default Action Buttons", "Botões de ação padrão renderizados automaticamente") do
          code_block do
            plain <<~CODE
              # Sem bloco = botões padrão (Cancelar + Salvar)
              form.action_buttons

              # Com bloco = customização total
              form.action_buttons do |actions|
                actions.cancel "Voltar"
                actions.submit "Criar Deal"
              end
            CODE
          end

          div(class: "mt-6") do
            render Components::ModelForm.new(model: Deal.new) do |form|
              form.attributes do
                form.attribute :agency
                form.attribute :description
              end

              # Botões padrão
              form.action_buttons
            end
          end
        end
      end

      def customization_examples
        section_card("Customization Options", "Personalize labels, placeholders, hints e mais") do
          code_block do
            plain <<~CODE
              form.attribute :agency,#{' '}
                label: "Agência Parceira",
                span: 6,
                required: true

              form.attribute :recruter,
                span: 6,
                required: true,
                hint: "Selecione o recrutador responsável"

              form.attribute :stage,
                include_blank: true,
                prompt: "Escolha uma etapa...",
                required: true

              form.attribute :description,
                placeholder: "Descreva os detalhes...",
                rows: 5,
                hint: "Seja o mais específico possível"
            CODE
          end

          div(class: "mt-6") do
            render Components::ModelForm.new(model: Deal.new) do |form|
              form.attributes do
                form.attribute :agency,
                  label: "Agência Parceira",
                  span: 6,
                  required: true

                form.attribute :recruter,
                  span: 6,
                  required: true,
                  hint: "Selecione o recrutador responsável"

                form.attribute :stage,
                  include_blank: true,
                  prompt: "Escolha uma etapa...",
                  required: true

                form.attribute :description,
                  placeholder: "Descreva os detalhes do deal...",
                  rows: 5,
                  hint: "Seja o mais específico possível"
              end

              form.action_buttons do |actions|
                actions.cancel "Cancelar"
                actions.submit "Salvar"
              end
            end
          end
        end
      end

      def layout_examples
        section_card("Layout & Grid", "Use span: para controlar o tamanho dos campos (1-12 colunas)") do
          code_block do
            plain <<~CODE
              # 2 colunas lado a lado (6 + 6 = 12)
              form.attribute :agency, span: 6
              form.attribute :recruter, span: 6

              # Coluna inteira
              form.attribute :stage, span: 12

              # 3 colunas (4 + 4 + 4 = 12)
              form.attribute :description, span: 4
            CODE
          end

          div(class: "mt-6") do
            render Components::ModelForm.new(model: Deal.new) do |form|
              form.attributes do
                form.attribute :agency, span: 6
                form.attribute :recruter, span: 6
                form.attribute :stage, span: 12
                form.attribute :description, span: 4, rows: 3
              end

              form.action_buttons do |actions|
                actions.submit "Salvar"
              end
            end
          end
        end
      end

      def validation_examples
        section_card("Validation & Errors", "Erros são exibidos automaticamente quando o model é inválido") do
          code_block do
            plain <<~CODE
              deal = Deal.new
              deal.valid? # Trigger validations

              render Components::ModelForm.new(model: deal) do |form|
                form.attributes do
                  form.attribute :agency, required: true
                  form.attribute :description, required: true
                end
              end
            CODE
          end

          div(class: "mt-6") do
            deal = Deal.new
            deal.valid? # Trigger validations

            render Components::ModelForm.new(model: deal) do |form|
              form.attributes do
                form.attribute :agency, required: true
                form.attribute :recruter, required: true
                form.attribute :stage, required: true
                form.attribute :description,
                  required: true,
                  hint: "Campo obrigatório"
              end

              form.action_buttons do |actions|
                actions.cancel "Cancelar"
                actions.submit "Salvar"
              end
            end
          end
        end
      end

      def section_card(title, description = nil, &block)
        div(class: "bg-white shadow-sm ring-1 ring-gray-900/5 sm:rounded-xl dark:bg-gray-800 dark:ring-white/10") do
          div(class: "px-4 py-6 sm:p-8") do
            h2(class: "text-lg font-semibold text-gray-900 dark:text-white mb-2") { title }
            if description
              p(class: "text-sm text-gray-600 dark:text-gray-400 mb-6") { description }
            end
            yield
          end
        end
      end

      def code_block(&block)
        pre(class: "bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto text-sm") do
          code do
            yield
          end
        end
      end
    end
  end
end
