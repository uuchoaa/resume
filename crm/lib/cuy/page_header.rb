class Cuy::PageHeader < Cuy::Base

  def initialize(title)
    @title = title
  end
  
  def view_template(&)
    div(class: "md:flex md:items-center md:justify-between") do
      div(class: "min-w-0 flex-1") do
        h2(
          class:
            "text-2xl/7 font-bold text-gray-900 sm:truncate sm:text-3xl sm:tracking-tight",
         ) { @title }
      end

      div(class: "mt-4 flex md:ml-4 md:mt-0", &)
    end
  end
end