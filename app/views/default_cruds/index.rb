module Views
  module DefaultCruds
    class Index < Views::Base
      def view_template(&)
        render Table.new(data_collection) do |table|
          table.column("ID") do |item|
            a(href: "/agencies/#{item.id}") { item.id }
          end
          table.column("Name", &:name)
        end
      end
    end
  end
end
