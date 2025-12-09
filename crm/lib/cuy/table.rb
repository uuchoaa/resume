class Cuy::Table < Cuy::Base
  def initialize(rows)
    @rows = rows
    @columns = []
  end

  def view_template(&)
    vanish(&)

    table(class: "relative min-w-full divide-y divide-gray-300") do
      thead do
        @columns.each do |column|
          th(scope: "col", class: "px-3 py-3.5 text-left text-sm font-semibold text-gray-900") { column[:header] }
        end
      end

      tbody(class: "divide-y divide-gray-200") do
        @rows.each do |row|
          tr do
            @columns.each do |column|
              td(class: "whitespace-nowrap px-3 py-4 text-sm text-gray-500") { column[:content].call(row) }
            end
          end
        end
      end
    end
  end

  def column(header, &content)
    @columns << { header:, content: }
    nil
  end
end