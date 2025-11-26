class Components::KanbanCard < Components::Base
  def initialize(deal:)
    @deal = deal
  end

  def view_template
    div(class: "bg-white rounded-lg shadow p-4 mb-3 hover:shadow-md transition cursor-pointer") do
      # Descrição
      h3(class: "font-semibold text-gray-900 text-sm mb-3") do
        plain @deal.description.truncate(60)
      end

      # Informações
      div(class: "space-y-2 text-sm text-gray-600 mb-3") do
        p(class: "flex items-center gap-2") do
          span { "🏢" }
          span { @deal.agency.name }
        end

        p(class: "flex items-center gap-2") do
          span { "👤" }
          span { @deal.recruter.name }
        end

        p(class: "flex items-center gap-2") do
          span { "📅" }
          span { I18n.l(@deal.created_at, format: :short) }
        end
      end

      # Link
      a(
        href: deal_path(@deal),
        class: "text-indigo-600 text-sm hover:text-indigo-800 font-medium"
      ) do
        plain "Ver detalhes →"
      end
    end
  end
end
