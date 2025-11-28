# frozen_string_literal: true

module Views
  module KitchenSink
    class Toast < Views::Base
      def page_title
        "Toast - Kitchen Sink"
      end

      def view_template
        render Components::PageHeader.new(
          title: page_title,
          description: "Sistema de notificações toast com 4 tipos diferentes"
        )

        div(class: "mt-8 space-y-8 max-w-4xl mx-auto") do
          # Exemplos estáticos
          static_examples

          # Botões para testar
          interactive_examples
        end
      end

      private

      def static_examples
        section_card("Tipos de Toast", "Diferentes tipos de notificações") do
          div(class: "space-y-4") do
            # Notice (Success)
            render Components::Toast.new(
              message: "Deal criado com sucesso!",
              description: "O deal foi salvo e está disponível para todos os usuários.",
              type: :notice
            )

            # Alert (Error)
            render Components::Toast.new(
              message: "Não foi possível criar o deal.",
              description: "Verifique os campos obrigatórios e tente novamente.",
              type: :alert
            )

            # Warning
            render Components::Toast.new(
              message: "Atenção: Esta ação não pode ser desfeita.",
              description: "Todos os dados relacionados serão removidos permanentemente.",
              type: :warning
            )

            # Info
            render Components::Toast.new(
              message: "Uma nova versão está disponível.",
              description: "Recarregue a página para ver as últimas atualizações.",
              type: :info
            )
          end
        end
      end

      def interactive_examples
        section_card("Teste Interativo", "Clique nos botões para ver os toasts em ação") do
          div(class: "flex flex-wrap gap-3") do
            # Notice button
            a(
              href: kitchen_sink_toast_path(flash: { notice: "Operação realizada com sucesso!" }),
              class: "inline-flex items-center gap-2 rounded-md bg-green-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-green-500"
            ) do
              plain "Mostrar Success"
            end

            # Alert button
            a(
              href: kitchen_sink_toast_path(flash: { alert: "Erro ao processar a requisição!" }),
              class: "inline-flex items-center gap-2 rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500"
            ) do
              plain "Mostrar Error"
            end

            # Warning button
            a(
              href: kitchen_sink_toast_path(flash: { warning: "Atenção: Esta é uma operação sensível!" }),
              class: "inline-flex items-center gap-2 rounded-md bg-yellow-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-yellow-500"
            ) do
              plain "Mostrar Warning"
            end

            # Info button
            a(
              href: kitchen_sink_toast_path(flash: { info: "Informação: Sistema será atualizado hoje à noite." }),
              class: "inline-flex items-center gap-2 rounded-md bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500"
            ) do
              plain "Mostrar Info"
            end
          end

          div(class: "mt-6 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg") do
            p(class: "text-sm text-gray-600 dark:text-gray-400") do
              plain "💡 Os toasts aparecem no canto superior direito, têm auto-dismiss após 5 segundos e podem ser fechados manualmente clicando no X."
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
    end
  end
end
