
module Views::Agencies
  class New < Views::Base

    def page_header
      render Cuy::PageHeader.new("Agencias") do
        # button(
        #   type: "button",
        #   class:
        #     "inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 dark:bg-white/10 dark:text-white dark:shadow-none dark:ring-white/5 dark:hover:bg-white/20"
        # ) { "Edit" }
        button(
          type: "button",
          class:
            "ml-3 inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-700 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600 dark:bg-indigo-500 dark:shadow-none dark:hover:bg-indigo-400 dark:focus-visible:outline-indigo-400"
        ) { "Publish" }
      end
    end

    def main_content
      p { "Aqui vai o form e tal..." }
      p { "path = #{current_path}"}
      code { @model.to_json }
    end

  end
end