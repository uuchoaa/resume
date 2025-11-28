class Components::Kanban < Components::Base
  def initialize(grouped_data:, columns:, column_translator:)
    @grouped_data = grouped_data
    @columns = columns
    @column_translator = column_translator
  end

  def view_template(&card_block)
    div(class: "flex gap-4 overflow-x-auto pb-4") do
      @columns.each do |column_key|
        render_column(column_key, &card_block)
      end
    end
  end

  private

  def render_column(column_key, &card_block)
    items = @grouped_data[column_key] || []

    div(class: "flex-shrink-0 w-80 bg-gray-100 rounded-lg p-4 min-h-[600px]") do
      # Header da coluna
      div(class: "flex items-center justify-between mb-4") do
        h3(class: "text-sm font-semibold text-gray-900") do
          plain @column_translator.call(column_key)
        end
        span(class: "text-sm font-medium text-gray-500") do
          plain "(#{items.size})"
        end
      end

      # Cards
      div(class: "space-y-3") do
        items.each do |item|
          card_block.call(item) if card_block
        end
      end
    end
  end
end
