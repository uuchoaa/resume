
module Views::Agencies
  class Index < Views::Base

    def page_header
      render Cuy::PageHeader.new("Agências") do
        button(
          type: "button",
          class:
            "ml-3 inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        ) { "Novo" }
      end
    end

    def main_content
      render Cuy::Table.new(@models) do |table|
        table.column("Name", &:name)
      end
      
    end

  end
end