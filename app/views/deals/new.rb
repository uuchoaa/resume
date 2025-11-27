module Views
  module Deals
    class New < Views::Base
      attr_accessor :deal, :agencies, :recruiters

      def page_title
        "Novo Deal"
      end

      def view_template
        render Components::PageHeader.new(page_title)

        div(class: "mt-8 max-w-2xl mx-auto") do
          div(class: "bg-white shadow-sm ring-1 ring-gray-900/5 sm:rounded-xl") do
            div(class: "px-4 py-6 sm:p-8") do
              render Components::Form.new(action: deals_path, method: :post) do |form|
                form.section(
                  title: "Personal Information",
                  description: "Use a permanent address where you can receive mail."
                ) do |section|
                  section.text :first_name,
                    label: "First name",
                    span: 3

                  section.text :last_name,
                    label: "Last name",
                    span: 3

                  section.email :email,
                    label: "Email address",
                    span: 4

                  section.select :country,
                    label: "Country",
                    span: 3,
                    options: [
                      { value: "US", label: "United States" },
                      { value: "CA", label: "Canada" },
                      { value: "MX", label: "Mexico" }
                    ],
                    selected: "US"

                  section.text :street_address,
                    label: "Street address",
                    span: :full

                  section.text :city,
                    label: "City",
                    span: 2

                  section.text :state,
                    label: "State / Province",
                    span: 2

                  section.text :postal_code,
                    label: "ZIP / Postal code",
                    span: 2
                end

                form.section(
                  title: "Informações Básicas",
                  description: "Dados principais do deal"
                ) do |section|
                  section.text :title,
                    label: "Título",
                    span: 4,
                    placeholder: "Ex: Desenvolvedor Senior Ruby"

                  section.email :contact_email,
                    label: "Email de contato",
                    span: 4,
                    placeholder: "you@example.com",
                    value: "adamwathan",
                    error: "Not a valid email address."

                  section.select :agency_id,
                    label: "Agência",
                    span: 3,
                    options: agencies.map { |a| { value: a.id, label: a.name } },
                    selected: deal.agency_id

                  section.select :recruter_id,
                    label: "Recrutador",
                    span: 3,
                    options: recruiters.map { |r| { value: r.id, label: r.name } },
                    selected: deal.recruter_id,
                    disabled: true

                  section.select :stage,
                    label: "Estágio",
                    span: 3,
                    options: Deal.stages.keys.map { |s| { value: s, label: Deal.human_attribute_name("stage.#{s}") } },
                    selected: deal.stage

                  section.textarea :description,
                    label: "Descrição",
                    span: :full,
                    rows: 4,
                    placeholder: "Descreva o deal...",
                    description: "Adicione detalhes sobre a vaga e o candidato",
                    value: deal.description
                end

                form.section(
                  title: "Estados dos Campos",
                  description: "Exemplos de estados: error, disabled, description"
                ) do |section|
                  section.text :example_error,
                    label: "Campo com erro",
                    span: 4,
                    value: "valor inválido",
                    error: "Este campo contém um erro"

                  section.text :example_disabled,
                    label: "Campo desabilitado",
                    span: 4,
                    value: "não editável",
                    disabled: true

                  section.text :example_hint,
                    label: "Campo com dica",
                    span: 4,
                    placeholder: "Digite algo...",
                    description: "Esta é uma mensagem de ajuda para o usuário"

                  section.textarea :example_textarea_error,
                    label: "Textarea com erro",
                    span: :full,
                    rows: 3,
                    value: "Texto com problema",
                    error: "Este texto contém erros"

                  section.textarea :example_textarea_disabled,
                    label: "Textarea desabilitado",
                    span: :full,
                    rows: 3,
                    value: "Este campo não pode ser editado",
                    disabled: true

                  section.textarea :example_textarea_hint,
                    label: "Textarea com dica",
                    span: :full,
                    rows: 3,
                    placeholder: "Digite uma descrição detalhada...",
                    description: "Forneça o máximo de detalhes possível"

                  section.select :example_select_error,
                    label: "Select com erro",
                    span: 3,
                    options: [
                      { value: "1", label: "Opção Inválida" },
                      { value: "2", label: "Opção 2" },
                      { value: "3", label: "Opção 3" }
                    ],
                    selected: "1",
                    error: "Seleção inválida"

                  section.select :example_select_disabled,
                    label: "Select desabilitado",
                    span: 3,
                    options: [
                      { value: "1", label: "Opção 1" },
                      { value: "2", label: "Opção 2" }
                    ],
                    selected: "1",
                    disabled: true

                  section.select :example_select_hint,
                    label: "Select com dica",
                    span: 3,
                    options: [
                      { value: "", label: "Selecione uma opção" },
                      { value: "1", label: "Opção 1" },
                      { value: "2", label: "Opção 2" }
                    ],
                    description: "Escolha a melhor opção disponível"

                  section.field(label: "Campo customizado", span: :full) do
                    div(class: "flex gap-4") do
                      input(
                        type: "text",
                        placeholder: "Parte 1",
                        class: "block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300"
                      )
                      input(
                        type: "text",
                        placeholder: "Parte 2",
                        class: "block w-full rounded-md bg-white px-3 py-1.5 text-base text-gray-900 outline outline-1 -outline-offset-1 outline-gray-300"
                      )
                    end
                  end
                end

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
