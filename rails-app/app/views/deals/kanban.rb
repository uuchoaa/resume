module Views
  module Deals
    class Kanban < Views::Base
      def page_title
        Deal.model_name.human(count: 2)
      end

      def view_template
        render_page_header
        render_kanban
      end

      private

      def render_page_header
        render Components::PageHeader.new(page_title) do |header|
          header.action("Novo", href: new_deal_path, primary: true)
        end
      end

      def render_kanban
        # Define ordem manual das colunas para garantir pipeline correto
        columns = [
          "open",
          "screening",
          "company_screening",
          "tech_assessment",
          "cultural_fit",
          "offer",
          "closed"
        ]

        # Agrupa deals por stage (retorna hash com keys como strings)
        grouped_data = data.group_by(&:stage)

        # Translator para nomes das colunas
        column_translator = ->(stage) { Deal.human_attribute_name("stage.#{stage}") }

        # Renderiza componente Kanban
        render Components::Kanban.new(
          grouped_data: grouped_data,
          columns: columns,
          column_translator: column_translator
        ) do |deal|
          render Components::KanbanCard.new(deal: deal)
        end
      end
    end
  end
end
