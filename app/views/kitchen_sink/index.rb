# frozen_string_literal: true

module Views
  module KitchenSink
    class Index < Views::Base
      def page_title
        "Kitchen Sink"
      end

      def view_template
        render Components::PageHeader.new(
          title: page_title,
          description: "Galeria de componentes e patterns do sistema"
        )

        div(class: "mt-8 max-w-7xl mx-auto") do
          div(class: "grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3") do
            component_card(
              title: "ModelForm",
              description: "API simplificada para forms com detecção automática de tipos",
              path: kitchen_sink_model_form_path,
              icon: "form",
              color: "indigo"
            )

            component_card(
              title: "Toast",
              description: "Sistema de notificações toast com 4 tipos diferentes",
              path: kitchen_sink_toast_path,
              icon: "notification",
              color: "green"
            )

            # Placeholder para futuros componentes
            component_card(
              title: "Table",
              description: "Componente de tabela com sorting e paginação (em breve)",
              path: "#",
              icon: "table",
              color: "gray",
              coming_soon: true
            )

            component_card(
              title: "Modal",
              description: "Modals e dialogs com Stimulus (em breve)",
              path: "#",
              icon: "modal",
              color: "gray",
              coming_soon: true
            )

            component_card(
              title: "Kanban",
              description: "Board kanban com drag & drop (em breve)",
              path: "#",
              icon: "kanban",
              color: "gray",
              coming_soon: true
            )

            component_card(
              title: "Form Components",
              description: "Inputs, selects, checkboxes e mais (em breve)",
              path: "#",
              icon: "components",
              color: "gray",
              coming_soon: true
            )
          end
        end
      end

      private

      def component_card(title:, description:, path:, icon:, color:, coming_soon: false)
        div(class: "relative group") do
          a(
            href: path,
            class: "block h-full rounded-lg bg-white shadow-sm ring-1 ring-gray-900/5 hover:shadow-md transition-shadow dark:bg-gray-800 dark:ring-white/10 #{coming_soon ? 'opacity-60 cursor-not-allowed' : ''}"
          ) do
            div(class: "p-6") do
              # Icon
              div(class: "flex items-center justify-center h-12 w-12 rounded-lg bg-#{color}-50 dark:bg-#{color}-900/20 mb-4") do
                render_icon(icon, color)
              end

              # Title
              h3(class: "text-lg font-semibold text-gray-900 dark:text-white mb-2") do
                plain title
                if coming_soon
                  span(class: "ml-2 text-xs font-normal text-gray-500 dark:text-gray-400") { "Em breve" }
                end
              end

              # Description
              p(class: "text-sm text-gray-600 dark:text-gray-400") { description }
            end
          end
        end
      end

      def render_icon(icon, color)
        case icon
        when "form"
          svg(class: "h-6 w-6 text-#{color}-600 dark:text-#{color}-400", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z")
          end
        when "notification"
          svg(class: "h-6 w-6 text-#{color}-600 dark:text-#{color}-400", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9")
          end
        else
          svg(class: "h-6 w-6 text-#{color}-600 dark:text-#{color}-400", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do |s|
            s.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M4 6h16M4 12h16M4 18h16")
          end
        end
      end
    end
  end
end
