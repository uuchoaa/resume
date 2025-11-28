class Components::KanbanCard < Components::Base
  def initialize(deal:)
    @deal = deal
  end

  def view_template
    div(class: "bg-white rounded-lg shadow p-4 mb-3 hover:shadow-md transition") do
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

      # Form para mudar stage
      render_stage_form

      # Link
      a(
        href: deal_path(@deal),
        class: "text-indigo-600 text-sm hover:text-indigo-800 font-medium block mt-3"
      ) do
        plain "Ver detalhes →"
      end
    end
  end

  private

  def render_stage_form
    form(
      action: deal_path(@deal),
      method: "post",
      data: { turbo_frame: "_top" }
    ) do
      # Hidden field para PATCH method
      input(type: "hidden", name: "_method", value: "patch")

      # CSRF token
      input(
        type: "hidden",
        name: "authenticity_token",
        value: form_authenticity_token
      )

      # Select de Stage
      render Components::Select.new(
        name: "deal[stage]",
        label: "Estágio",
        options: stage_options,
        selected: @deal.stage,
        id: "deal_stage_#{@deal.id}"
      )
    end
  end

  def stage_options
    Deal.stages.keys.map do |stage|
      {
        value: stage,
        label: Deal.human_attribute_name("stage.#{stage}")
      }
    end
  end
end
