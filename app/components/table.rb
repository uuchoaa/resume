class Components::Table < Components::Base
  def initialize(rows)
    @rows = rows
    @columns = []
  end

  def view_template(&)
    vanish(&)

    table(class: "relative min-w-full divide-y divide-gray-300 dark:divide-white/15") do
      thead do
        @columns.each do |column|
          th(scope: "col", class: "px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-white") { column[:header] }
        end
      end

      tbody(class: "divide-y divide-gray-200 dark:divide-white/10") do
        @rows.each do |row|
          tr do
            @columns.each do |column|
              td(class: "whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400") { column[:content].call(row) }
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
