class Components::Nav < Components::Base
  attr_reader :request_path

  def initialize(request_path)
    @request_path = request_path
  end

  def view_template(&)
    div(class: "hidden sm:-my-px sm:ml-6 sm:flex sm:space-x-8", &)
  end

  def item(href, &)
    active_variant = "inline-flex items-center border-b-2 border-indigo-600 px-1 pt-1 text-sm font-medium text-gray-900"
    default_variant = "inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700"

    a(class: request_path.starts_with?(href) ? active_variant : default_variant, href:, &)
  end

  def divider
    # span(class: "special-nav-divider")
  end
end
